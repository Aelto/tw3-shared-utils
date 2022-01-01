
/**
 * This latent function is great if you want to offer a dialog choice in an
 * imperative way. The downside is that it is latent and it may be a bit complex
 * to use in some cases like exec functions.
 * If you don't want to use a latent function, use the event based solution.
 */
latent function SU_setDialogChoicesAndWaitForResponse(choices: array<SSceneChoice>): SSceneChoice {
  var hud: CR4ScriptedHud;
  var dialogueModule: CR4HudModuleDialog;
  var accepted_choice: SSceneChoice;
  var null: SSceneChoice;

  hud = (CR4ScriptedHud)theGame.GetHud();

  if (!hud) {
    LogChannel('SharedUtils', "SU_setDialogChoicesAndWaitForResponse - could not get HUD");

    return null;
  }

  // setting the dialog choices
  dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
  dialogueModule.OnDialogChoicesSet( choices, false );

  // set the value to false before starting, in case it was already at true
  // and not properly reset.
  dialogueModule.isAcceptedChoiceAvailable = false;

  // telling the game to display the cutscene UI
  theInput.SetContext( 'Scene' );
  theGame.SetIsDialogOrCutscenePlaying(true);
  hud.OnCutsceneStarted();

  // wait for the player to accept one of the dialog choices
  while (!dialogueModule.isAcceptedChoiceAvailable
      && theInput.GetContext() == 'Scene'
      && theGame.IsDialogOrCutscenePlaying()) {
    SleepOneFrame();
  }

  // we fetch the last accepted choice
  accepted_choice = dialogueModule.lastAcceptedChoice;
  // and we remember to set it back to NULL
  dialogueModule.lastAcceptedChoice = null;

  // when it stopped because of a change of context and not a user selected
  // choice.
  if (!dialogueModule.isAcceptedChoiceAvailable) {
    accepted_choice = null;
  }

  dialogueModule.isAcceptedChoiceAvailable = false;

  return accepted_choice;
}

/**
 * This is the class you're supposed to extend and implement to listen to the
 * onResponse event.
 *
 * NOTE: that the response listener is removed whenever the onResponse event is
 * triggered. If you want to listen to every response then you will have to set
 * back the listener yourself in the onResponse method.
 */
abstract class SU_DialogChoiceResponseListener {

  /**
   * Override this method to add your own custom logic.
   */
  function onResponse(choice: SSceneChoice, available_choices: array<SSceneChoice>, module_dialog: CR4HudModuleDialog) {}

}

/**
 * This is the function for an event based dialog choice. Much more appropriate
 * for exec functions and small dialogs with few branches.
 */
function SU_setDialogChoicesAndResponseListener(choices: array<SSceneChoice>, response_listener: SU_DialogChoiceResponseListener): bool {
  var hud: CR4ScriptedHud;
  var dialogueModule: CR4HudModuleDialog;
  var accepted_choice: SSceneChoice;
  var null: SSceneChoice;

  hud = (CR4ScriptedHud)theGame.GetHud();

  if (!hud) {
    LogChannel('SharedUtils', "SU_setDialogChoicesAndWaitForResponse - could not get HUD");

    return false;
  }

  // setting the dialog choices
  dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
  dialogueModule.responseListener = response_listener;
  dialogueModule.OnDialogChoicesSet(choices, false);

  theInput.SetContext( 'Scene' );
  theGame.SetIsDialogOrCutscenePlaying(true);
  hud.OnCutsceneStarted();

  return true;
}

/**
 * This function is to properly close the dialog choice interface, use it when
 * you're done with the dialog choices.
 */
function SU_closeDialogChoiceInterface() {
  var hud : CR4ScriptedHud;

  theInput.SetContext( 'Exploration' );
  theGame.SetIsDialogOrCutscenePlaying(false);
  theGame.GetGuiManager().RequestMouseCursor(false);

  hud = (CR4ScriptedHud)theGame.GetHud();
  if( hud ) {
    hud.OnCutsceneEnded();
  }
}