
/**
 * an empty state mainly for logging
 */
state Waiting in SU_JournalQuestEntry {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "Quest [" + parent.tag + "] - state Waiting");
  }
}
