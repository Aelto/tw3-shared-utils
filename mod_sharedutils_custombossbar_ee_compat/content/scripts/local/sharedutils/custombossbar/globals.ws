function SU_showCustomBossBar(entity_name: string, use_essence: bool) {
  var bossFocusModule : CR4HudModuleBossFocus;
  var hud : CR4ScriptedHud;

  hud = (CR4ScriptedHud)theGame.GetHud();
  if (hud) {
    bossFocusModule = (CR4HudModuleBossFocus)hud.GetHudModule("BossFocusModule");

    if(bossFocusModule) {
      bossFocusModule.show(entity_name, use_essence);
    }
  }
}

function SU_setCustomBossBarPercent(value: float) {
  var bossFocusModule : CR4HudModuleBossFocus;
  var hud : CR4ScriptedHud;

  hud = (CR4ScriptedHud)theGame.GetHud();
  if (hud) {
    bossFocusModule = (CR4HudModuleBossFocus)hud.GetHudModule("BossFocusModule");

    if(bossFocusModule) {
      bossFocusModule.setCurrentPercentage(value);
    }
  }
}

function SU_hideCustomBossBar() {
  var bossFocusModule : CR4HudModuleBossFocus;
  var hud : CR4ScriptedHud;

  hud = (CR4ScriptedHud)theGame.GetHud();
  if (hud) {
    bossFocusModule = (CR4HudModuleBossFocus)hud.GetHudModule("BossFocusModule");

    if(bossFocusModule) {
      bossFocusModule.hide();
    }
  }
}