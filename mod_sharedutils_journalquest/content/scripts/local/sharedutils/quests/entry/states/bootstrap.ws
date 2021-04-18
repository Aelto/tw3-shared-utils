
state Bootstrap in SU_JournalQuestEntry {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "quest [" + parent.tag + "] - state Bootstrap");

    this.Bootstrap_main();
  }

  entry function Bootstrap_main() {
    this.gotoCurrentChapterState();
  }

  function gotoCurrentChapterState() {
    var current_chapter: SU_JournalQuestChapter;

    current_chapter = parent.chapters[parent.current_chapter];

    parent.GotoState(current_chapter.chapter_state);
  }
}
