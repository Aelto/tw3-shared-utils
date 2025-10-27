@addField(CR4HudModuleControlsFeedback)
var su_input_context: SU_InputContext;

@wrapMethod(CR4HudModuleControlsFeedback)
function SendInputContextActions(inputContextName: name, optional isForced : bool) {
  var listeners: array<SU_InputContext_InputListenerInfo>;
  var flash_array: CScriptedFlashArray;
  var i: int;

  if (this.su_input_context) {
    flash_array = this.m_flashValueStorage.CreateTempFlashArray();
    listeners = this.su_input_context.getInputListeners();

    for (i = 0; i < listeners.Size(); i += 1) {
      flash_array.PushBackFlashObject(
        SU_createContextKeyBindingData(
          this.m_flashValueStorage,
          SU_getKeyForAction(listeners[i].action),
          listeners[i].label
        )
      );
    }

    if (listeners.Size() >= 0) {
      this.m_flashValueStorage.SetFlashArray(
        KEY_CONTROLS_FEEDBACK_LIST,
        flash_array
      );
    }
  }
  else {
    wrappedMethod(inputContextName, isForced);
  }
}

function SU_createContextKeyBindingData(
  storage: CScriptedFlashValueStorage,
  key: EInputKey,
  label: string
): CScriptedFlashObject {
  var object: CScriptedFlashObject;
  var data: CScriptedFlashObject;

  object = storage.CreateTempFlashObject();
  data = object.CreateFlashObject("red.game.witcher3.data.KeyBindingData");

  data.SetMemberFlashInt("gamepad_keyCode", key);
  data.SetMemberFlashInt("keyboard_keyCode", key);
  data.SetMemberFlashString("label", label);

  return data;
}

function SU_getKeyForAction(action: name): EInputKey {
  var using_keyboard: bool = theInput.LastUsedPCInput();
  var keys: array<EInputKey>;

  theInput.GetCurrentKeysForAction(action, keys);

  return keys[0];
}