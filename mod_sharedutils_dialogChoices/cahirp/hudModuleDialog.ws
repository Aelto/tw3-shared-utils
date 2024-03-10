@context(
  define(mod.sharedutils.dialogChoices)
  file("game/gui/hud/modules/hudModuleDialog.ws")
  at(class CR4HudModuleDialog)
)

@insert(
  at(OnDialogOptionAccepted)
)
// sharedutils - dialogchoices - BEGIN
public var lastAcceptedChoice: SSceneChoice;
public var isAcceptedChoiceAvailable: bool;
public var responseListener: SU_DialogChoiceResponseListener;
// sharedutils - dialogchoices - END

@insert(
  at(OnDialogOptionAccepted)
  above(acceptedChoice = lastSetChoices[index])
)
// sharedutils - dialogchoices - BEGIN
var listener: SU_DialogChoiceResponseListener;
// sharedutils - dialogchoices - END

@insert(
  at(OnDialogOptionAccepted)
  above(if (!acceptedChoice.disabled))
)
// sharedutils - dialogchoices - BEGIN
this.lastAcceptedChoice = acceptedChoice;
this.isAcceptedChoiceAvailable = true;

if (this.responseListener) {
  listener = this.responseListener;
  this.responseListener = NULL;

  listener.onResponse(acceptedChoice, lastSetChoices, this);
}
// sharedutils - dialogchoices - END