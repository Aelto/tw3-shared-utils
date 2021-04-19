
/**
 * this state is set when the quest is bootstrapped, which means after a loading
 * screen and:
 *  - the quest was active and in this state
 *  - the quest was set active through the quest journal
 * That means that it won't enter this state when progressing from one chapter
 * to another.
 */
state Bootstrap in SU_JournalQuestChapter extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "chapter [" + parent.tag + "] - state Bootstrap");
    parent.nextState();
  }
}
