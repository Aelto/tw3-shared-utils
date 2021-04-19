
/**
 * inject the objectives to display in the journal UI
 */
function SU_injectQuestObjectives(out flasharray: CScriptedFlashArray, quest_tag: name, storage: CScriptedFlashValueStorage, binding: string, expansionIconFlashFunction: CScriptedFlashFunction): bool {
  var objectives: array<SU_JournalQuestChapterObjective>;
  var quest_entry: SU_JournalQuestEntry;
  var i, offset: int;

  // LogChannel('SU', "inject objectives for quest " + quest_tag);

  if (SU_getJournalQuestEntryByUniqueTag(quest_tag, quest_entry)) {
    // LogChannel('SU', "inject objectives for quest " + quest_tag + " found");


    objectives = quest_entry.getCompletedObjectives();
    for (i = 0; i < objectives.Size(); i += 1) {
      flasharray.PushBackFlashObject(SU_getFlashDataFromQuestChapterObjective(objectives[i], true, i, storage));
    }

    // LogChannel('SU', "found " + i + " completed objectives");

    objectives = quest_entry.getActiveObjectives();
    for (i = 0; i < objectives.Size(); i += 1) {
      flasharray.PushBackFlashObject(SU_getFlashDataFromQuestChapterObjective(objectives[i], false, i + offset, storage));
    }

    // LogChannel('SU', "found " + i + " active objectives");

    offset = i;

    storage.SetFlashArray( binding, flasharray );
		storage.SetFlashString( binding + ".questname", quest_entry.title);
		
		expansionIconFlashFunction.InvokeSelfOneArg( FlashArgInt( quest_entry.episode ) );

    return true;
  }

  return false;
}

function SU_getFlashDataFromQuestChapterObjective(objective: SU_JournalQuestChapterObjective, is_completed: bool, index: int, storage: CScriptedFlashValueStorage): CScriptedFlashObject {
  var output: CScriptedFlashObject;

  output = storage.CreateTempFlashObject();
  output.SetMemberFlashUInt(  "tag", NameToFlashUInt(objective.unique_tag) ); 
  output.SetMemberFlashBool( "isNew", false );
  output.SetMemberFlashBool( "tracked", false );
  output.SetMemberFlashBool( "isLegend", false );

  if (is_completed) {
    output.SetMemberFlashInt( "status", JS_Success );
  }
  else {
    output.SetMemberFlashInt( "status", JS_Active );
  }
  
  // LogChannel('SU', "injected objective label = " + objective.label);
  output.SetMemberFlashString(  "label", objective.label );
  output.SetMemberFlashInt( "phaseIndex", 1 );
  output.SetMemberFlashInt( "objectiveIndex", index );
  output.SetMemberFlashBool( "isMutuallyExclusive", false );

  return output;
}

/**
 * inject the objectives to display in the quest module (right part of the 
 * screen)
 */
function SU_injectQuestModuleObjectives(out flasharray: CScriptedFlashArray, storage: CScriptedFlashValueStorage): bool {
  var objectives: array<SU_JournalQuestChapterObjective>;
  var quest_entry: SU_JournalQuestEntry;
  var temp_object: CScriptedFlashObject;
  var i: int;

  if (!SU_getFirstTrackedQuest(quest_entry)) {
    return false;
  }

  objectives = quest_entry.getActiveObjectives();
  for (i = 0; i < objectives.Size(); i += 1) {
    temp_object = storage.CreateTempFlashObject();
    temp_object.SetMemberFlashString("name", objectives[i].label);
    temp_object.SetMemberFlashBool("isHighlighted", true);
    temp_object.SetMemberFlashBool("isMutuallyExclusive", false);
    temp_object.SetMemberFlashBool("isNew", false);
    flasharray.PushBackFlashObject(temp_object);
  }

  storage.SetFlashArray( "hud.quest.system.objectives", flasharray );

  return true;
}

function SU_injectQuestModuleName(flashfunction: CScriptedFlashFunction): bool {
  var quest_entry: SU_JournalQuestEntry;

  if (!SU_getFirstTrackedQuest(quest_entry)) {
    return false;
  }

  flashfunction.InvokeSelfThreeArgs(
    FlashArgString(quest_entry.title),
    FlashArgInt(SU_getColorByQuestType(quest_entry.type)),
    FlashArgBool(false)
  );

  return true;
}

function SU_getColorByQuestType( type: eQuestType ) : int
	{
		switch ( type )
		{
		case Story:
			return 0xffcc00;
		case Chapter:
			return 0xbb8237;
		case Side:
		case MonsterHunt:
		case TreasureHunt:
			return 0xc0c0c0;
		}
		return 0xffffff;
	}