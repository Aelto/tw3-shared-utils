
function SU_injectQuestEntries(out flasharray: CScriptedFlashArray, current_selected_tag: name, menu: CR4JournalQuestMenu, storage: CScriptedFlashValueStorage) {
  var current_entry: SU_JournalQuestEntry;
  var i: int;

  for (i = 0; i < thePlayer.journal_quest_entries.Size(); i += 1) {
    current_entry = thePlayer.journal_quest_entries[i];

    flasharray.PushBackFlashObject(
      SU_getFlashDataFromQuestEntry(
        current_entry,
        current_selected_tag,
        menu,
        storage
      )
    );
  }
}

function SU_getFlashDataFromQuestEntry(quest_entry: SU_JournalQuestEntry, current_selected_tag: name, menu: CR4JournalQuestMenu, storage: CScriptedFlashValueStorage): CScriptedFlashObject {
  var output: CScriptedFlashObject;

  output = storage.CreateTempFlashObject();

  if (quest_entry.difficulty == SU_JournalQuestEntryDifficulty_EASY) {
    output.SetMemberFlashString( "reqdifficulty", "<font color='#969696'>"
      + GetLocStringByKeyExt('panel_item_required_level')
      + " "
      + thePlayer.GetLevel()
      + "</font>"
    );

    output.SetMemberFlashString( "area",
      "<font color='#969696'>"
      + thePlayer.GetLevel()
      + "</font>"
    );
  }
  else if (quest_entry.difficulty == SU_JournalQuestEntryDifficulty_MEDIUM) {
    output.SetMemberFlashString( "reqdifficulty",
      "<font color='#d68f29'>"
      + GetLocStringByKeyExt('panel_item_required_level')
      + " "
      + thePlayer.GetLevel()
      + "</font>"
    );

    output.SetMemberFlashString( "area",
      "<font color='#d68f29'>"
      + thePlayer.GetLevel()
      + "</font>"
    );
  }
  else if (quest_entry.difficulty == SU_JournalQuestEntryDifficulty_HARD) {
    output.SetMemberFlashString("reqdifficulty",
      "<font color='#d61010'>"
      + GetLocStringByKeyExt('panel_item_required_level')
      + " "
      + thePlayer.GetLevel()
      + "</font>"
    );

    output.SetMemberFlashString("area",
      "<font color='#d61010'>"
      + thePlayer.GetLevel()
      + "</font>"
    );
  }

  output.SetMemberFlashString("title", quest_entry.title);
  output.SetMemberFlashString( "description", quest_entry.getFullDescriptionFromChapters() );

  output.SetMemberFlashUInt(  "tag", NameToFlashUInt(quest_entry.unique_tag) );
  
  output.SetMemberFlashString(  "dropDownLabel", "Custom Quests" );
  output.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt('CustomQuests') );

  output.SetMemberFlashBool(  "dropDownOpened", false );
  output.SetMemberFlashBool( "selected", quest_entry.unique_tag == current_selected_tag );

  output.SetMemberFlashInt( "isStory", quest_entry.type );
  output.SetMemberFlashInt( "epIndex", quest_entry.episode );
  output.SetMemberFlashString( "iconPath", menu.GetQuestIconByType( quest_entry.type, quest_entry.episode ) );
  output.SetMemberFlashBool( "isNew", false );
  output.SetMemberFlashInt( "curWorld", theGame.GetCommonMapManager().GetCurrentJournalArea() );
  output.SetMemberFlashInt( "questWorld", 0 ); // TODO
  output.SetMemberFlashString("status", quest_entry.status);
  output.SetMemberFlashString("label", quest_entry.title);
  output.SetMemberFlashString("secondLabel", GetLocStringByKeyExt(SU_getSecondLabelFromAreaName(quest_entry.area)));
  output.SetMemberFlashString("isdeadlydifficulty", quest_entry.difficulty == SU_JournalQuestEntryDifficulty_HARD);
  output.SetMemberFlashBool("tracked", quest_entry.is_tracked);


  return output;
}

function SU_getSecondLabelFromAreaName(area: EAreaName): name {
  switch (area) {
    case AN_Undefined:
      return 'panel_journal_filters_area_any';
    case AN_NMLandNovigrad:
      return 'panel_journal_filters_area_no_mans_land';
    case AN_Skellige_ArdSkellig:
      return 'panel_journal_filters_area_skellige';
    case AN_Kaer_Morhen:
      return 'panel_journal_filters_area_kaer_morhen';
    case AN_Prologue_Village:
      return 'panel_journal_filters_area_prolgue_village';
    case AN_Wyzima:
      return 'panel_journal_filters_area_wyzima';
    case AN_Island_of_Myst:
      return 'panel_journal_filters_area_island_of_myst';
    case AN_Spiral:
      return 'panel_journal_filters_area_spiral';
    case AN_Prologue_Village_Winter:
      return 'panel_journal_filters_area_prolgue_village';
    case AN_Velen:
      return 'panel_journal_filters_area_velen';
    case (EAreaName)AN_Dlc_Bob:
      return 'panel_journal_filters_area_bob';
  }

  return 'panel_journal_filters_area_any';
}