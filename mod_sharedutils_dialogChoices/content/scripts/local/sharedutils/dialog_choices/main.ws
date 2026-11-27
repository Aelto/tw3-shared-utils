
/**
 * This latent function is great if you want to offer a dialog choice in an
 * imperative way. The downside is that it is latent and it may be a bit complex
 * to use in some cases like exec functions.
 * If you don't want to use a latent function, use the event based solution.
 */
latent function SU_setDialogChoicesAndWaitForResponse(choices: array<SSceneChoice>): SSceneChoice {
  var dialogueModule: CR4HudModuleDialog;
  var choice: SSceneChoice;

  // while on gamepad, the interact input is directly sent in the dialog choice
  // it is safer to wait a bit before capturing the input.
  Sleep(0.25);

  dialogueModule = SU_setDialogChoices(choices);

  if (!dialogueModule) {
    return choice;
  }

  // wait for the player to accept one of the dialog choices
  while (SU_isDialogChoiceCurrentlyPlaying(dialogueModule)) {
    SleepOneFrame();
  }

  SleepOneFrame();

  choice = SU_getLastAcceptedChoiceAndFlushDialog(dialogueModule);

  // when a choice is accepted the game hides the mouse cursor itself but if
  // the dialog was interrupted (player attacked, change of context...) the
  // cursor request has to be released here, otherwise the cursor would stay
  // visible forever.
  SU_releaseDialogChoicesCursor(dialogueModule);

  return choice;
}

function SU_setDialogChoices(choices: array<SSceneChoice>): CR4HudModuleDialog {
  var dialogueModule: CR4HudModuleDialog;
  var nullModule: CR4HudModuleDialog;
  var nullChoice: SSceneChoice;
  var hud: CR4ScriptedHud;

  hud = (CR4ScriptedHud)theGame.GetHud();

  if (!hud) {
    LogChannel('SharedUtils', "SU_setDialogChoicesAndWaitForResponse - could not get HUD");

    return nullModule;
  }

  dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");

  // a previous dialog may not have been closed properly, its mouse cursor
  // request is released first to keep the cursor requests balanced.
  SU_releaseDialogChoicesCursor(dialogueModule);

  // setting the dialog choices
  dialogueModule.OnDialogChoicesSet( choices, false );

  // resetting the state of a dialog that would not have been properly closed,
  // and tracking the cursor request of this new dialog.
  dialogueModule.lastAcceptedChoice = nullChoice;
  dialogueModule.isAcceptedChoiceAvailable = false;
  dialogueModule.responseListener = NULL;
  dialogueModule.su_dialogChoicesOpen = true;

  // telling the game to display the cutscene UI
  theInput.SetContext( 'Scene' );
  theGame.SetIsDialogOrCutscenePlaying(true);
  hud.OnCutsceneStarted();

  return dialogueModule;
}

function SU_isDialogChoiceCurrentlyPlaying(dialogueModule: CR4HudModuleDialog): bool {
  return !dialogueModule.isAcceptedChoiceAvailable
      && theInput.GetContext() == 'Scene'
      && theGame.IsDialogOrCutscenePlaying();
}

function SU_getLastAcceptedChoiceAndFlushDialog(dialogueModule: CR4HudModuleDialog): SSceneChoice {
  var accepted_choice: SSceneChoice;
  var null: SSceneChoice;

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

  // send an empty array to flush the data, without touching the mouse cursor
  // requests, OnDialogChoicesSet would request the cursor again for the empty
  // set of choices.
  dialogueModule.SU_flushDialogChoices();

  return accepted_choice;
}

/**
 * Releases the mouse cursor request made when the dialog choices were set.
 * The request is only ever released once per dialog, either here or by the
 * game when a choice is accepted, so that closing a dialog can never hide a
 * cursor request owned by something else.
 */
function SU_releaseDialogChoicesCursor(dialogueModule: CR4HudModuleDialog) {
  if (dialogueModule && dialogueModule.su_dialogChoicesOpen) {
    dialogueModule.su_dialogChoicesOpen = false;
    theGame.GetGuiManager().RequestMouseCursor(false);
  }
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

  dialogueModule = SU_setDialogChoices(choices);
  dialogueModule.responseListener = response_listener;

  return true;
}

/**
 * This function is to properly close the dialog choice interface, use it when
 * you're done with the dialog choices.
 */
function SU_closeDialogChoiceInterface() {
  var hud : CR4ScriptedHud;
  var dialogueModule : CR4HudModuleDialog;

  theInput.SetContext(thePlayer.GetExplorationInputContext());
  theGame.SetIsDialogOrCutscenePlaying(false);
  theGame.ForceUIAnalog(false);

  hud = (CR4ScriptedHud)theGame.GetHud();
  if( hud ) {
    dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");

    if (dialogueModule) {
      dialogueModule.isAcceptedChoiceAvailable = false;
      dialogueModule.responseListener = NULL;

      // clear the choices that would otherwise stay displayed on screen
      dialogueModule.SU_flushDialogChoices();
    }

    hud.OnCutsceneEnded();

    // kept last so that nothing can request the cursor back afterwards
    if (dialogueModule) {
      SU_releaseDialogChoicesCursor(dialogueModule);
    }
  }
}
