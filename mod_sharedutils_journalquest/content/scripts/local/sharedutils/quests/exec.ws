
exec function SU_clearJournalQuestEntries() {
  thePlayer.journal_quest_entries.Clear();
}

statemachine class SU_QuestTest extends SU_JournalQuestEntry {
  default tag = "SU_QuestTest";
  default unique_tag = 'SU_QuestTest';
  default is_tracked = false;
  default type = Side;
  default status = JS_Active;
  default difficulty = SU_JournalQuestEntryDifficulty_EASY;
  default area = AN_Velen;
  default title = "This is a test quest";
  default episode = SU_JournalQuestEntryEpisodeCORE;
}

state QuestTestChapterOne in SU_QuestTest {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "state - QuestTestChapterOne");

    this.QuestTestChapterOne_main();
  }

  entry function QuestTestChapterOne_main() {
    theGame
    .GetGuiManager()
    .ShowNotification("QuestTestChapterOne", 10);
  }
}

class QTchapterOne extends SU_JournalQuestChapter {
  public function init(quest_entry: SU_JournalQuestEntry): QTchapterOne {
    this.tag = "QuestTestChapterOne";
    this.chapter_state = 'QuestTestChapterOne';
    this.setLocalizedDescriptionWhenActive("description_when_active");
    this.setLocalizedDescriptionWhenCompleted("description_when_completed");

    this.addObjective(
      (new SU_JournalQuestChapterObjectives in thePlayer)
      .setTags('objective_one_tag')
      .setLabel("objective_one_label")
    );

    return this;
  }
}



exec function suaddjournalquestentry() {
  var quest_entry: SU_QuestTest;

  quest_entry = new SU_QuestTest in thePlayer;

  quest_entry.addChapter((new QTchapterOne in thePlayer).init(quest_entry));

  thePlayer.addJournalQuestEntry(quest_entry);
}
