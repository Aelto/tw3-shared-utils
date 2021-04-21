
/**
 * injects a journal update about the supplied chapter.
 */
function SU_injectCustomJournalUpdate(chapter: SU_JournalQuestChapter, optional is_success: bool) {
	var journal_update_module: CR4HudModuleJournalUpdate;
  var update: SJournalUpdate;
  var hud: CR4ScriptedHud;

	hud = (CR4ScriptedHud)theGame.GetHud();	

  if (!hud) {
    return;
  }
	
  journal_update_module = (CR4HudModuleJournalUpdate)hud.GetHudModule("journal_update_module");

  if (!journal_update_module) {
    return;
  }
  
  update = SJournalUpdate();
  update.title = chapter.quest_entry.title;
  update.text = chapter.objectives[0].label;
  update.isQuestUpdate = true;
  update.displayTime = 3000;
  update.entryTag = chapter.quest_entry.unique_tag;

  if (is_success) {
    update.status = JS_Success;
  }
  else {
    update.status = JS_Active;
  }

  journal_update_module.addCustomJournalUpdate(update);
}

function SU_tryTrackCustomQuest(unique_tag: name): bool {
  var quest_entry: SU_JournalQuestEntry;

  if (!SU_getJournalQuestEntryByUniqueTag(unique_tag, quest_entry)) {
    return false;
  }

  return true;
}