
abstract class SU_DialogHoverListener {
  function onHover(scene_choice: SSceneChoice, index: int) {

  }
}

function SU_addDialogHoverListener(listener: SU_DialogHoverListener): bool {
  var hud: CR4ScriptedHud;
  var dialogueModule: CR4HudModuleDialog;

  hud = (CR4ScriptedHud)theGame.GetHud();

  if (!hud) {
    LogChannel('SharedUtils', "SU_addDialogHoverListener - could not get HUD");

    return false;
  }

  dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
  dialogueModule.dialog_hover_listeners.PushBack(listener);

  return true;
}

function SU_removeDialogHoverListener(listener: SU_DialogHoverListener): bool {
  var hud: CR4ScriptedHud;
  var dialogueModule: CR4HudModuleDialog;

  hud = (CR4ScriptedHud)theGame.GetHud();

  if (!hud) {
    LogChannel('SharedUtils', "SU_setDialogChoicesAndWaitForResponse - could not get HUD");

    return false;
  }

  dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
  dialogueModule.dialog_hover_listeners.Remove(listener);

  return true;
}

function SU_clearDialogHoverListeners(): bool {
  var hud: CR4ScriptedHud;
  var dialogueModule: CR4HudModuleDialog;

  hud = (CR4ScriptedHud)theGame.GetHud();

  if (!hud) {
    LogChannel('SharedUtils', "SU_setDialogChoicesAndWaitForResponse - could not get HUD");

    return false;
  }

  dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
  dialogueModule.dialog_hover_listeners.Clear();

  return true;
}

function SU_triggerEventListeners(module: CR4HudModuleDialog, choice: SSceneChoice, index: int) {
  var i: int;

  for (i = 0; i < module.dialog_hover_listeners.Size(); i += 1) {
    module.dialog_hover_listeners[i].onHover(choice, index);
  }
}