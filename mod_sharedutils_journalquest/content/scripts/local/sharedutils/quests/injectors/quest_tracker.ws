
function SU_isThereAnyQuestToTrackFromObjectiveHighlight(objective_tag: name, quest_tag: name): bool {
  var quest_entry: SU_JournalQuestEntry;
  var null: CJournalQuest;

  if (!SU_getJournalQuestEntryByUniqueTag(quest_tag, quest_entry)) {
    SU_untrackAllQuestsWithTagsDifferentThan(quest_tag);
    return false;
  }

  if (!quest_entry.getCurrentChapter().hasObjectiveWithUniqueTag(objective_tag)) {
    SU_untrackAllQuestsWithTagsDifferentThan(quest_tag);
    return false;
  }


  if (!quest_entry.is_tracked) {
    SU_untrackAllQuestsWithTagsDifferentThan(quest_tag);

    quest_entry.trackQuest();
    theSound.SoundEvent("gui_journal_track_quest");

    // we also tell the game to update the objective on the right.
    theGame.GetGuiManager()
      .GetHudEventController()
      .RunEvent_QuestsModule_OnQuestTrackingStarted(null);
  }

  return true;
}

function SU_untrackAllQuestsWithTagsDifferentThan(tag: name) {
  var is_tracked: bool;
  var i: int;

  for (i = 0; i < thePlayer.journal_quest_entries.Size(); i += 1) {
    is_tracked = thePlayer.journal_quest_entries[i].is_tracked;
    
    if (is_tracked && thePlayer.journal_quest_entries[i].unique_tag != tag) {
      thePlayer.journal_quest_entries[i].untrackQuest();
    }
  }
}