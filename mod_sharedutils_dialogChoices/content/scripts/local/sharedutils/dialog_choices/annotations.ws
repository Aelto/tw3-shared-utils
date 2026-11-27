@addField(CR4HudModuleDialog)
var lastAcceptedChoice: SSceneChoice;

@addField(CR4HudModuleDialog)
var isAcceptedChoiceAvailable: bool;

@addField(CR4HudModuleDialog)
var responseListener: SU_DialogChoiceResponseListener;

/**
 * Tracks the mouse cursor request made when the dialog choices were set, it
 * is released once either by the game (accepted choice) or by sharedutils
 * (interrupted dialog or manual close).
 */
@addField(CR4HudModuleDialog)
var su_dialogChoicesOpen: bool;

/**
 * Clears the choices currently displayed on screen. OnDialogChoicesSet always
 * requests the mouse cursor, even for an empty set of choices, and an
 * unmatched request keeps the cursor visible forever, so the request is
 * compensated right away.
 */
@addMethod(CR4HudModuleDialog)
function SU_flushDialogChoices() {
  var empty_choices: array<SSceneChoice>;

  this.OnDialogChoicesSet( empty_choices, false );
  theGame.GetGuiManager().RequestMouseCursor(false);
  theGame.ForceUIAnalog(false);
}

@wrapMethod(CR4HudModuleDialog)
function OnDialogOptionAccepted( index : int ) {
  var listener: SU_DialogChoiceResponseListener;
  var acceptedChoice : SSceneChoice;
  var canAccept: bool;

  acceptedChoice = lastSetChoices[index];

  // the game refuses the disabled choices it can't do anything with, the
  // choice should only be marked as accepted when the game accepts it as
  // well, that is also when the game releases the mouse cursor request.
  canAccept = !acceptedChoice.disabled
    || (acceptedChoice.dialogAction == DialogAction_CONTENT_MISSING
      && theGame.IsContentAvailable(acceptedChoice.playGoChunk));

  if (canAccept) {
    this.lastAcceptedChoice = acceptedChoice;
    this.isAcceptedChoiceAvailable = true;

    // the wrapped method hides the mouse cursor for accepted choices, the
    // request of this dialog is considered released from this point on.
    this.su_dialogChoicesOpen = false;

    if (this.responseListener) {
      listener = this.responseListener;
      this.responseListener = NULL;

      listener.onResponse(acceptedChoice, this.lastSetChoices, this);
    }
  }

  return wrappedMethod(index);
}

/**
 * Safety net for the dialogs interrupted without any accepted choice, e.g.
 * when the player is attacked and the game switches back to a gameplay input
 * context. Without this nothing would release the mouse cursor requested
 * when the choices were displayed, leaving the cursor visible forever.
 */
@wrapMethod(CR4HudModuleDialog)
function OnTick( timeDelta : float ) {
  var hud: CR4ScriptedHud;

  if (su_dialogChoicesOpen
      && !isAcceptedChoiceAvailable
      && theInput.GetContext() != 'Scene'
      && !theGame.GetGuiManager().IsAnyMenu()) {

    isAcceptedChoiceAvailable = false;
    responseListener = NULL;

    SU_flushDialogChoices();

    theGame.SetIsDialogOrCutscenePlaying(false);

    hud = (CR4ScriptedHud)theGame.GetHud();
    if (hud) {
      hud.OnCutsceneEnded();
    }

    SU_releaseDialogChoicesCursor(this);
  }

  wrappedMethod(timeDelta);
}
