
function SU_addCustomCooldown(cooldown: SU_Cooldown) {
  var module: CR4HudModuleBuffs;

  module = (CR4HudModuleBuffs)theGame
    .GetHud()
    .GetHudModule('BuffsModule');

  module.addCustomCooldown(cooldown);
  module.SetEnabled(true);
}

function SU_removeCustomCooldown(cooldown: SU_Cooldown) {
  var module: CR4HudModuleBuffs;

  module = (CR4HudModuleBuffs)theGame
    .GetHud()
    .GetHudModule('BuffsModule');

  module.removeCustomCooldown(cooldown);
}