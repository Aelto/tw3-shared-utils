@addField(CR4HudModuleDialog)
var lastAcceptedChoice: SSceneChoice;

@addField(CR4HudModuleDialog)
var isAcceptedChoiceAvailable: bool;

@addField(CR4HudModuleDialog)
var responseListener: SU_DialogChoiceResponseListener;

@wrapMethod(CR4HudModuleDialog)
function OnDialogOptionAccepted( index : int ) {
  var listener: SU_DialogChoiceResponseListener;
  var acceptedChoice : SSceneChoice;

  acceptedChoice = lastSetChoices[index];

  this.lastAcceptedChoice = acceptedChoice;
  this.isAcceptedChoiceAvailable = true;

  if (this.responseListener) {
    listener = this.responseListener;
    this.responseListener = NULL;

    listener.onResponse(acceptedChoice, this.lastSetChoices, this);
  }

  return wrappedMethod(index);
}