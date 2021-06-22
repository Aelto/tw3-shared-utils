
exec function SU_clearJournalQuestEntries() {
  thePlayer.journal_quest_entries.Clear();
}

exec function SU_progress(optional chapter: string) {
  var qentry: SU_JournalQuestEntry;
  var i: int;

  NDEBUG("found quests: " + thePlayer.journal_quest_entries.Size());
  for (i = 0; i < thePlayer.journal_quest_entries.Size(); i += 1) {
    qentry = thePlayer.journal_quest_entries[i];

    if (!qentry.is_tracked) {
      continue;
    }

    qentry.completeCurrentChapterAndGoToNext(chapter);
  }
}

exec function SU_rollback() {
  var qentry: SU_JournalQuestEntry;
  var chapter: SU_JournalQuestChapter;
  var i: int;

  NDEBUG("found quests: " + thePlayer.journal_quest_entries.Size());
  for (i = 0; i < thePlayer.journal_quest_entries.Size(); i += 1) {
    qentry = thePlayer.journal_quest_entries[i];

    if (!qentry.is_tracked) {
      continue;
    }

    chapter = qentry.chapters[qentry.current_chapter - 1];
    qentry.completeCurrentChapterAndGoToNext(chapter.tag);
  }
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
      .setLabel("Search the area and look for a suspicious man")
      .addPin((new SU_MapPin in thePlayer).init(
        "tag_one",
        thePlayer.GetWorldPosition() + Vector(30, 30),
        "Look for a suspicious man in the area",
        "Objective position",
        "MonsterQuest",
        10,
        "no_mans_land"
      ))
    );

    return this;
  }
}

state Progress in QTchapterOne extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    this.Progress_main();
    parent.nextState();
  }

  entry function Progress_main() {
    var template: CEntityTemplate;
    var tags_array: array<name>;
    var template_path: string;
    var position: Vector;
    var pin: SU_MapPin;
    
    tags_array.PushBack('SU_QuestTest_EntityGraden');
    template_path = "quests\secondary_npcs\graden.w2ent";
    template = (CEntityTemplate)LoadResourceAsync(template_path, true);

    pin = parent
      .getObjectiveWithUniqueTag('objective_one_tag')
      .getFirstPin();

    position = thePlayer.GetWorldPosition();
    position = Vector(pin.position.X, pin.position.Y, position.Z);
    this.groundPosition(position);

    LogChannel('SU', "ground position " + VecToString(position));
    
    theGame.CreateEntity(
      template,
      position + Vector(0, 0, 0.5),
      thePlayer.GetWorldRotation(),,,,
      PM_Persist,
      tags_array
    );
  }
}

state Running in QTchapterOne extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    this.Running_main();
  }

  entry function Running_main() {
    var pin: SU_MapPin;

    if (!this.isPlayerInRegion("no_mans_land")) {
      theGame
      .GetGuiManager()
      .ShowNotification("wrong region");

      return;
    }

    pin = parent
      .getObjectiveWithUniqueTag('objective_one_tag')
      .getFirstPin();

    this.waitForPlayerToReachPoint(pin.position, pin.radius);
    parent.quest_entry.completeCurrentChapterAndGoToNext();
  }
}

statemachine class QTchapterTwo extends SU_JournalQuestChapter {
  public function init(quest_entry: SU_JournalQuestEntry): QTchapterTwo {
    this.tag = "QuestTestchapterTwo";
    this.setLocalizedDescriptionWhenActive("description_when_active");
    this.setLocalizedDescriptionWhenCompleted("description_when_completed");

    this.addObjective(
      (new SU_JournalQuestChapterObjective in thePlayer)
      .setTags('objective_two_tag')
      .setLabel("Talk to the suspicious man")
      .addPin((new SU_MapPin in thePlayer).init(
        "tag_one",
        thePlayer.GetWorldPosition() + Vector(30, 30),
        "Talk to the suspicious man",
        "Objective position",
        "MonsterQuest",
        0,
        "no_mans_land"
      ))
    );

    return this;
  }
}

state Progress in QTchapterTwo extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    this.Progress_main();
    parent.nextState();
  }

  entry function Progress_main() {
    var npc: CEntity;

    npc = theGame.GetEntityByTag('SU_QuestTest_EntityGraden');

    // we make the NPC talk a bit:
    // Graden: You're a witcher. Will you help?
    ((CActor)npc).PlayLine(519794, true);
  }
}

state Running in QTchapterTwo extends BaseChapter {
  event OnEnterState(previous_state_name: name) {
    this.Running_main();
  }

  entry function Running_main() {
    var npc: CEntity;
    
    npc = theGame.GetEntityByTag('SU_QuestTest_EntityGraden');
    
    this.waitUntilInteraction((CPeristentEntity)npc);
    this.showDialogChoices(npc);    
  }

  latent function showDialogChoices(npc: CEntity) {
    var choices: array<SSceneChoice>;
    var response: SSceneChoice;

    choices.PushBack(SSceneChoice(
      "Who are you?",
      true,
      false,
      false,
      DialogAction_MONSTERCONTRACT,
      'WhoAreYou'
    ));

    choices.PushBack(SSceneChoice(
      "Farewell.",
      false,
      false,
      false,
      DialogAction_GETBACK,
      'CloseDialog'
    ));


    while (true) {
      response = SU_setDialogChoicesAndWaitForResponse(choices);
      SU_closeDialogChoiceInterface();

      if (response.playGoChunk == 'WhoAreYou') {
        thePlayer.PlayLine(405291, true); // Who are you?
        thePlayer.WaitForEndOfSpeach();
        ((CActor)npc).PlayLine(401785, true);
        ((CActor)npc).WaitForEndOfSpeach();
      }

      if (response.playGoChunk == 'CloseDialog') {
        thePlayer.PlayLine(452638, true);

        return;
      }
    }
  }
}

exec function suaddjournalquestentry() {
  var quest_entry: SU_QuestTest;

  quest_entry = new SU_QuestTest in thePlayer;

  quest_entry.addChapter((new QTchapterOne in thePlayer).init(quest_entry));
  quest_entry.addChapter((new QTchapterTwo in thePlayer).init(quest_entry));

  thePlayer.addJournalQuestEntry(quest_entry);
}
