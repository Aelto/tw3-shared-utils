
/**
 * this state is called when the quest progressed to another chapter and this
 * chapter should now be closed.
 */
state Closing in SU_JournalQuestChapter extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "chapter [" + parent.tag + "] - state Closing");

    this.Closing_main();

  }

  entry function Closing_main() {
    parent.GotoState('Closed');
  }
}
