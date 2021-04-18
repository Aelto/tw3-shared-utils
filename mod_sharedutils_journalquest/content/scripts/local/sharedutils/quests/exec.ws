
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

statemachine class QTchapterOne extends SU_JournalQuestChapter {
  public function init(quest_entry: SU_JournalQuestEntry): QTchapterOne {
    this.tag = "QuestTestChapterOne";
    this.setLocalizedDescriptionWhenActive("description_when_active");
    this.setLocalizedDescriptionWhenCompleted("description_when_completed");

    this.addObjective(
      (new SU_JournalQuestChapterObjective in thePlayer)
      .setTags('objective_one_tag')
      .setLabel("objective_one_label")
      .addPin((new SU_MapPin in thePlayer).init(
        "tag_one",
        thePlayer.GetWorldPosition() + Vector(30, 30),
        "Go there and get a reward",
        "Objective position",
        "MonsterQuest",
        10,
        "no_mans_land"
      ))
    );

    return this;
  }
}

state Running in QTchapterOne extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    LogChannel('SU', "state - Running");

    this.QuestTestChapterOne_main();
  }

  entry function QuestTestChapterOne_main() {
    var pin: SU_MapPin;

    LogChannel('SU', "current region = " + this.getCurrentRegion());

    if (!this.isPlayerInRegion("no_mans_land")) {
      theGame
      .GetGuiManager()
      .ShowNotification("wrong region");

      return;
    }

    pin = parent
      .getObjectiveWithUniqueTag('objective_one_tag')
      .getFirstPin();

    if (pin) {
      LogChannel('SU', "Look at your map and reach the position = " + VecToString(pin.position));

      this.waitForPlayerToReachPoint(pin.position, pin.radius);

      theGame
      .GetGuiManager()
      .ShowNotification("Good job!");
    }
    else {
      LogChannel('SU', "could not find the first pin");
    }
  }
}



exec function suaddjournalquestentry() {
  var quest_entry: SU_QuestTest;

  quest_entry = new SU_QuestTest in thePlayer;

  quest_entry.addChapter((new QTchapterOne in thePlayer).init(quest_entry));

  thePlayer.addJournalQuestEntry(quest_entry);
}
