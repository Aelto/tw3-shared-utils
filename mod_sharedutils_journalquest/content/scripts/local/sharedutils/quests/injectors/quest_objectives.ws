
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