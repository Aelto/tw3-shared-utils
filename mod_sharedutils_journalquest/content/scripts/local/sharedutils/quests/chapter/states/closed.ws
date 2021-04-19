
/**
 * this state should not have any logic in it. It is used by the QuestEntry
 * class to detect when the chapter has finally closed and the quest can
 * progress to the next chapter.
 */
state Closed in SU_JournalQuestChapter extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "chapter [" + parent.tag + "] - state Closed");
    parent.nextState();
  }
}
