
/**
 * this state is where the main logic for the chapter is. It is called after the
 * Bootstrap state.
 *
 * NOTE: that this state doesn't go anywhere and never call GotoState because
 * instead you should call the QuestEntry quest and call its method:
 *   completeCurrentChapterAndGoToNext(next_chapter_tag)
 */
state Running in SU_JournalQuestChapter extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "chapter [" + parent.tag + "] - state Running");
  }
}
