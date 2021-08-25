
function SU_addCustomCooldown(cooldown: SU_Cooldown) {
  var module: CR4HudModuleBuffs;

  cooldown.injection_time = theGame.GetEngineTimeAsSeconds();

  module = (CR4HudModuleBuffs)theGame
    .GetHud()
    .GetHudModule('BuffsModule');

  thePlayer.custom_cooldowns.PushBack(cooldown);

  module.ForceUpdate();
  module.SetEnabled(true);
}

function SU_removeCustomCooldown(cooldown: SU_Cooldown) {
  var module: CR4HudModuleBuffs;

  module = (CR4HudModuleBuffs)theGame
    .GetHud()
    .GetHudModule('BuffsModule');

  thePlayer.custom_cooldowns.Remove(cooldown);

  module.ForceUpdate();
  module.UpdateBuffs();
}