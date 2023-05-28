const path = require("path");
const fs = require("fs");
const { execSync } = require("child_process");

// the modules to backport to oldgen
const modules = fs
  .readdirSync(path.join(__dirname, ".."))
  .filter((name) => name.startsWith("mod_sharedutils"))
  .filter((name) => name === "mod_sharedutils_storage");

console.log(`backporting following modules: \n- ${modules.join("\n- ")}`);

if (!fs.existsSync("backported-modules")) {
  fs.mkdirSync("backported-modules");
}

for (const su_module of modules) {
  const mods = fs.readdirSync(path.join(__dirname, "mods"));
  const mods_to_remove = mods.filter((name) => name !== "modOldGenVanilla");

  for (const mod of mods_to_remove) {
    console.log(`removing ${mods_to_remove}`);
    fs.rmSync(path.join(__dirname, "mods", mod), {
      recursive: true,
      force: true,
    });
  }

  console.log(`copying ${su_module} into mods folder`);
  fs.cpSync(
    path.join(__dirname, "..", su_module),
    path.join(__dirname, "mods", su_module),
    { recursive: true }
  );

  const command = `tw3-script-merger --source "modNextGenVanilla/content/scripts" --input "mods" --output "output" --clean`;
  execSync(command);

  moveModFilesFromOutput(su_module);
}

function moveModFilesFromOutput(su_module) {
  const module_path = path.join(__dirname, "mods", su_module);
  const backported_module_path = path.join(
    __dirname,
    "backported-modules",
    su_module
  );

  // copy the directory in the backported modules
  fs.cpSync(module_path, backported_module_path, {
    recursive: true,
  });

  const module_scripts = path.join(module_path, "content", "scripts");

  // get all the .ws files from this module that are not local files
  const module_files = execSync(`dir /s /b ${module_scripts}`, {
    encoding: "utf-8",
  })
    .split("\n")
    .map((name) => name.trim())
    .filter((name) => name.endsWith(".ws") && !name.includes("local"));

  console.log(`files from ${su_module}: \n- ${module_files.join("\n- ")}`);

  const output_path = path.join(__dirname, "output");
  for (const file of module_files) {
    const before = file.replace(
      path.join(module_path, "content", "scripts"),
      output_path
    );
    const after = file.replace(module_path, backported_module_path);
    fs.copyFileSync(before, after);
  }
}
