
/**
 * this state is set when the quest progresses from one chapter to another, and
 * only then.
 * This state is called BEFORE the Bootstrap state
 */
state Progress in SU_JournalQuestChapter extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "chapter [" + parent.tag + "] - state Progress");
    parent.nextState();
  }
}
