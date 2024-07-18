@addField(CR4HudModuleDialog)
var dialog_hover_listeners: array<SU_DialogHoverListener>;

@wrapMethod(CR4HudModuleDialog)
event OnDialogOptionSelected(index: int) {
  var result: bool;

  result = wrappedMethod(index);
  SU_triggerEventListeners(this, this.lastSetChoices[index], index);

  return result;
}