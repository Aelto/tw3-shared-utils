
/**
 * this state is only there to progress from one chapter to another. Because it
 * needed to be a latent function but on a different thread than the chapters
 * that call it, otherwise the function would have been stopped even before it
 * finishes because the chapter changes state and cancel everything in the
 * thread.
 */
state Progressing in SU_JournalQuestEntry {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "Quest [" + parent.tag + "] - state Progressing");

    this.Progressing_main();
    parent.GotoState('Waiting');
  }

  entry function Progressing_main() {
    var chapter: SU_JournalQuestChapter;
    var null: CJournalQuest;
    
    chapter = parent.getCurrentChapter();

    // it's a latent function and it could take a few frames to finish
    chapter.closeChapter();
    chapter.untrack();

    parent.completed_chapters.PushBack(parent.current_chapter);
    
    parent.current_chapter = parent.next_chapter;
    parent.chapters[parent.current_chapter].GotoState('Progress');
    parent.chapters[parent.current_chapter].track();

    // we also tell the game to update the objective on the right.
    theGame.GetGuiManager()
      .GetHudEventController()
      .RunEvent_QuestsModule_OnQuestTrackingStarted(null);

    SU_injectCustomJournalUpdate(parent.chapters[parent.current_chapter]);
  }
}
