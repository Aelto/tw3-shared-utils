
function SU_addCustomCooldown(cooldown: SU_Cooldown) {
  var module: CR4HudModuleBuffs;

  cooldown.injection_time = theGame.GetEngineTimeAsSeconds();

  module = SU_getBuffsModule();

  thePlayer.custom_cooldowns.PushBack(cooldown);

  module.ForceUpdate();
  module.SetEnabled(true);
}

function SU_removeCustomCooldown(cooldown: SU_Cooldown) {
  var module: CR4HudModuleBuffs;

  module = SU_getBuffsModule();

  thePlayer.custom_cooldowns.Remove(cooldown);

  SU_refreshCustomCooldownInterface(module);
}

function SU_refreshCustomCooldownInterface(module: CR4HudModuleBuffs) {
  module.ForceUpdate();
  module.UpdateBuffs();
}

function SU_hasCooldownWithTitle(title: string): bool {
  var i: int;

  for (i = 0; i < thePlayer.custom_cooldowns.Size(); i += 1) {
    if (thePlayer.custom_cooldowns[i].title == title) {
      return true;
    }
  }

  return false;
}

function SU_getBuffsModule(): CR4HudModuleBuffs {
  return (CR4HudModuleBuffs)theGame
    .GetHud()
    .GetHudModule('BuffsModule');
}