
/**
 * workflow of the statemachine:
 *  - Progress: if it comes from a previous chapter
 *  - Bootstrap: every loading screen or when the player tracks the quest or
 *    simply after Progress
 *  - Running: after Bootstrap
 *  - Closing: after calling QuestEntry::completeCurrentChapterAndGoToNext
 *  - Closed: after Closing and when ready to move on to the next chapter
 */
statemachine class SU_JournalQuestChapter extends CEntity {
  /**
   * the unique tag would should be used to identify the chapter among the
   * others.
   */
  var tag: string;

  /**
   * The description is the string that appears in the journal quest UI. Like in
   * vanilla for each chapter in the quest the quest's description has a unique
   * paragraph about it.
   * This variable holds the string that will be used when the chapter is
   * still active and not completed yet.
   */
  var description_when_active: string;

  /**
   * The description is the string that appears in the journal quest UI. Like in
   * vanilla for each chapter in the quest the quest's description has a unique
   * paragraph about it.
   * This variable holds the string that will be used when the chapter is
   * completed and not active.
   */
  var description_when_completed: string;

  /**
   * The list of objectives for this chapter, there is no way to set one 
   * objective as completed while keeping the other uncompleted. The objectives
   * are all set as completed when the chapter is set completed itself.
   *
   * If you want to create separated objectives, simply create a different
   * chapter.
   *
   * This in a array in case you want to display optional objectives.
   */
  var objectives: array<SU_JournalQuestChapterObjective>;

  /**
   * do not set it yourself, it will be set automatically when you add the
   * chapter to the questEntry's list of chapters.
   */
  var quest_entry: SU_JournalQuestEntry;

  /** 
   * a chainable helper to easily add an objective without having to hold
   * the instance in a variable.
   */
  function addObjective(objective: SU_JournalQuestChapterObjective): SU_JournalQuestChapter {
    this.objectives.PushBack(objective);

    return this;
  }

  /**
   * a chainable helper to easily set the localized description when active,
   * without having to hikd the instance in a variable.
   **/
  function setLocalizedDescriptionWhenActive(key: string): SU_JournalQuestChapter {
    this.description_when_active = GetLocStringByKey(key);

    return this;
  }

  /**
   * a chainable helper to easily set the localized description when active,
   * without having to hikd the instance in a variable.
   **/
  function setLocalizedDescriptionWhenCompleted(key: string): SU_JournalQuestChapter {
    this.description_when_completed = GetLocStringByKey(key);

    return this;
  }

  /**
   * returns whether one of its objective has the same tag as the supplied tag.
   */
  function hasObjectiveWithUniqueTag(tag: name): bool {
    var i: int;

    for (i = 0; i < this.objectives.Size(); i += 1) {
      if (this.objectives[i].unique_tag == tag) {
        return true;
      }
    }

    return false;
  }

  /**
   * returns the first objective that has the same tag as the supplied tag.
   */
  function getObjectiveWithUniqueTag(tag: name): SU_JournalQuestChapterObjective {
    var null: SU_JournalQuestChapterObjective;
    var i: int;

    for (i = 0; i < this.objectives.Size(); i += 1) {
      if (this.objectives[i].unique_tag == tag) {
        return this.objectives[i];
      }
    }

    return null;
  }

  /**
   * show the markers from its list of objectives
   */
  function track() {
    var null: CJournalQuest;
    var i: int;

    for (i = 0; i < this.objectives.Size(); i += 1) {
      this.objectives[i].track();
    }

    // we also tell the game to update the objective on the right.
    theGame.GetGuiManager()
      .GetHudEventController()
      .RunEvent_QuestsModule_OnQuestTrackingStarted(null);
  }

  /**
   * hide the markers from its list of objectives
   */
  function untrack() {
    var i: int;

    for (i = 0; i < this.objectives.Size(); i += 1) {
      this.objectives[i].untrack();
    }
  }

  /**
   * small helper to prevent you from having to remember the full workflow
   * of the Chapter statemachine
   */
  protected function nextState() {
    var current_state: name;
    
    current_state = this.GetCurrentStateName();

    if (current_state == 'Progress') {
      LogChannel('SU', "Chapter [" + this.tag + "] - current state [" + current_state + "] - going to [Bootstrap]");
      this.GotoState('Bootstrap');
    }
    if (current_state == 'Bootstrap') {
      LogChannel('SU', "Chapter [" + this.tag + "] - current state [" + current_state + "] - going to [Running]");
      this.GotoState('Running');
    }
    if (current_state == 'Running') {
      LogChannel('SU', "Chapter [" + this.tag + "] - current state [" + current_state + "] - going nowhere");
      // don't do anything, instead you should call the function:
      // SU_JournalQuestEntry::completeCurrentChapterAndGoToNext()
    }
    if (current_state == 'Closing') {
      LogChannel('SU', "Chapter [" + this.tag + "] - current state [" + current_state + "] - going to [Closed]");
      this.GotoState('Closed');
    }
  }

  /**
   * it's a function that is called by the QuestEntry when we ask it to move to
   * the next chapter. Do not call it yourself.
   */
  latent function closeChapter() {
    this.GotoState('Closing');

    while (this.GetCurrentStateName() != 'Closed') {
      SleepOneFrame();
    }
  }
}