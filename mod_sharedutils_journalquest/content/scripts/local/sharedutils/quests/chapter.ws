
class SU_JournalQuestChapter {
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
   * The main class for the quest is a statemachine, and if you want to add
   * custom code for your chapter it should sit in a unique state.
   * This variables holds the name of the state. 
   */
  var chapter_state: name;

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
  var objectives: array<SU_JournalQuestChapterObjectives>;

  /** 
   * a chainable helper to easily add an objective without having to hold
   * the instance in a variable.
   */
  function addObjective(objective: SU_JournalQuestChapterObjectives): SU_JournalQuestChapter {
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
   *
   */
  function track() {
    var i: int;

    for (i = 0; i < this.objectives.Size(); i += 1) {
      this.objectives[i].track();
    }
  }

  /**
   *
   */
  function untrack() {
    var i: int;

    for (i = 0; i < this.objectives.Size(); i += 1) {
      this.objectives[i].untrack();
    }
  }

  /**
   * this function is called when the quest progresses from this chapter to the
   * next. You can override it to implement your own cleaning logic.
   */
  public latent function clean(next_chapter_tag: string) {}
}