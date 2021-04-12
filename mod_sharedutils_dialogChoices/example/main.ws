
/**
 * This is a basic response listener that will take the choice, and eventually
 * add a new choice to the set of response and send it back to the player,
 * or simply leave the dialog choice.
 */
class SU_ExampleResponseListener extends SU_DialogChoiceResponseListener {

  function onResponse(choice: SSceneChoice, available_choices: array<SSceneChoice>, module_dialog: CR4HudModuleDialog) {
    if (choice.playGoChunk == 'CloseDialog') {
      SU_closeDialogChoiceInterface();

      return;
    }

    if (choice.playGoChunk == 'AddNewDialogChoice') {
      available_choices.PushBack(SSceneChoice(
        "This is a new choice that doesn't do anything, #" + available_choices.Size(),
        false,
        false,
        false,
        DialogAction_CONTENT_MISSING,
        'DoNothing'
      ));
    }

    /**
     * Notice how we pass `this` again, because we still want this response
     * listener to handle the new responses.
     */
    SU_setDialogChoicesAndResponseListener(available_choices, this);
  }

}

/**
 * We create the initial two choices.
 * - the first one is made to add a new dialogue option in the list of choices
 * - the second one is to leave the dialog choice
 */ 
exec function SU_test() {
  var choices: array<SSceneChoice>;

  choices.PushBack(SSceneChoice(
    "Add a new choice",
    true,
    false,
    false,
    DialogAction_MONSTERCONTRACT,
    'AddNewDialogChoice'
  ));

  choices.PushBack(SSceneChoice(
    "Close dialog",
    true,
    false,
    false,
    DialogAction_GETBACK,
    'CloseDialog'
  ));

  SU_setDialogChoicesAndResponseListener(choices, new SU_ExampleResponseListener in thePlayer);
}

