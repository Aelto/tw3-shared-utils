
abstract statemachine class SU_JournalQuestEntry {
  var tag: string;

  /**
   * used by the UI, it can be the same value as the tag, but with the name type
   */
  var unique_tag: name;

  /**
   * Set if the class is tracked and its markers are displayed on the map and 
   * it code is running. 
   */
  var is_tracked: bool;

  /**
   * possible values:
   * - Story
   * - Chapter
   * - Side
   * - MonsterHunt
   * - TreasureHunt
   */
  var type: eQuestType;
  default type = Side;

  var status: EJournalStatus;
  default status = JS_Active;

  var difficulty: SU_JournalQuestEntryDifficulty;
  default difficulty = SU_JournalQuestEntryDifficulty_EASY;

  var area: EAreaName;

  var title: string;

  var episode: SU_JournalQuestEntryEpisode;
  default episode = SU_JournalQuestEntryEpisodeCORE;


  /**
   * The list of all chapters this quest has. The only way to play a chapter is
   * to start by adding it to this list.
   */
  var chapters: array<SU_JournalQuestChapter>;

  /**
   * use the index of the chapters in `this.chapters`
   */
  var completed_chapters: array<int>;

  /**
   * use the index of the chapters in `this.chapters`
   */
  var current_chapter: int;
  default current_chapter = -1;

  /**
   * uses the index of the chapters in `this.chapter`
   */
  var next_chapter: int;
  default next_chapter = -1;

  /**
   * an helper function to easily add chapters to the quest.
   * It returns `this` so it is chainable.
   */
  public function addChapter(chapter: SU_JournalQuestChapter): SU_JournalQuestEntry {
    chapter.quest_entry = this;

    this.chapters.PushBack(chapter);

    return this;
  }

  /**
   * returns the first chapter's index from `this.chapters` that has the same
   * tag as the supplied one.
   * returns -1 if it didn't find any chapter with the tag.
   */
  public function getChapterIndexByTag(tag: string): int {
    var i: int;

    for (i = 0; i < this.chapters.Size(); i += 1) {
      if (this.chapters[i].tag == tag) {
        return i;
      }
    }

    return -1;
  }

  /**
   * returns the current chapter. This function doesn't do any bound check and
   * may crash if the index is out of bounds, but it is not its goal to report
   * an error at this point and it's better to crash the game.
   */
  public function getCurrentChapter(): SU_JournalQuestChapter {
    // important detail here, we do a Max() call here because by default the
    // current_chapter index is at -1. And so we wouldn't get any objective
    // while the quest has not started yet.
    return this.chapters[Max(this.current_chapter, 0)];
  }

  /**
   * moves the current chapter in the list of completed chapters and move to the
   * next chapter.
   * This function does a this.GotoState() to the next chapter's state.
   */
  public function completeCurrentChapterAndGoToNext(optional chapter_tag: string) {
    if (StrLen(chapter_tag) > 0) {
      this.next_chapter = this.getChapterIndexByTag(chapter_tag);

      if (this.next_chapter < 0) {
        theGame
        .GetGuiManager()
        .ShowNotification("ERROR: no chapter with tag: " + chapter_tag, 20);

        return;
      }
    }
    else {
      this.next_chapter = this.current_chapter + 1;
    }

    this.GotoState('Progressing');
  }

  /**
   * returns the list of objectives from the list of completed chapters
   */
  public function getCompletedObjectives(): array<SU_JournalQuestChapterObjective> {
    var output: array<SU_JournalQuestChapterObjective>;
    var current_chapter: SU_JournalQuestChapter;
    var chapter_index: int;
    var i, k: int;

    for (i = 0; i < this.completed_chapters.Size(); i += 1) {
      chapter_index = this.completed_chapters[i];
      current_chapter = this.chapters[chapter_index];

      for (k = 0; k < current_chapter.objectives.Size(); k += 1) {
        output.PushBack(current_chapter.objectives[k]);
      }
    }

    return output;
  }

  /**
   * returns the list of objectives from the currently active chapter.
   */
  public function getActiveObjectives(): array<SU_JournalQuestChapterObjective> {
    var output: array<SU_JournalQuestChapterObjective>;
    var current_chapter: SU_JournalQuestChapter;
    var i: int;

    current_chapter = this.getCurrentChapter();
    
    return current_chapter.objectives;
  }

  /**
   * returns the full description from all previously completed chapters and
   * the current chapter
   */
  public function getFullDescriptionFromChapters(): string {
    var current_chapter: SU_JournalQuestChapter;
    var chapter_index: int;
    var output: string;
    var i, k: int;

    for (i = 0; i < this.completed_chapters.Size(); i += 1) {
      chapter_index = this.completed_chapters[i];
      current_chapter = this.chapters[chapter_index];

      for (k = 0; k < current_chapter.objectives.Size(); k += 1) {
        output += current_chapter.description_when_completed;
      }
    }

    current_chapter = this.chapters[this.current_chapter];
    output += current_chapter.description_when_completed;

    return output;
  }

  /**
   * set the quest as tracked and also start tracking the current chapter.
   */
  public function trackQuest() {
    LogChannel('SU', "tracking quest " + this.tag + ", is tracked =" + this.is_tracked);

    if (this.is_tracked) {
      return;
    }

    this.is_tracked = true;
    this.bootstrap();
  }

  /**
   * stop tracking the quest and its current chapter.
   */
  public function untrackQuest() {
    this.is_tracked = false;
    this.chapters[this.current_chapter].untrack();
  }

  public function bootstrap() {
    var current_chapter: SU_JournalQuestChapter;

    // this.current_chapter is at -1 by default to indicate the quest has not
    // started yet. When it is the case, we put this.current_chapter to 0
    // but instead of bootstrapping the mod we set its state to `Progress`
    //
    // If you're confused about this, read the comment above the Chapter class
    // about its workflow. TL;DR: the Progress state is the state where 
    // initialization code should run only the first time the chapter is
    // bootstrapped.
    if (this.current_chapter < 0) {
      this.current_chapter = 0;

      current_chapter = this.chapters[this.current_chapter];
      current_chapter.GotoState('Progress');
    }
    else {
      current_chapter = this.chapters[this.current_chapter];
      current_chapter.GotoState('Bootstrap');
    }

    current_chapter.track();
  }
}

enum SU_JournalQuestEntryDifficulty {
  SU_JournalQuestEntryDifficulty_EASY = 0,
  SU_JournalQuestEntryDifficulty_MEDIUM = 1,
  SU_JournalQuestEntryDifficulty_HARD = 2,
}

enum SU_JournalQuestEntryEpisode {
  SU_JournalQuestEntryEpisodeCORE = 0,
  SU_JournalQuestEntryEpisodeHEARTOFSTONE = 1,
  SU_JournalQuestEntryEpisodeBLOODANDWINE = 2,
}

/**
 * utility function to get a journal quest entry by its tag. Returns true if it
 * found one, or false if it didn't.
 */
function SU_getJournalQuestEntryByTag(tag: string, out quest_entry: SU_JournalQuestEntry): bool {
  var entries: array<SU_JournalQuestEntry>;
  var i: int;

  entries = thePlayer.journal_quest_entries;

  for (i = 0; i < entries.Size(); i += 1) {
    if (entries[i].tag == tag) {
      quest_entry = entries[i];
      
      return true;
    }
  }

  return false;
}

/**
 * utility function to get a journal quest entry by unique its tag. Returns true
 * if it found one, or false if it didn't.
 */
function SU_getJournalQuestEntryByUniqueTag(tag: name, out quest_entry: SU_JournalQuestEntry): bool {
  var entries: array<SU_JournalQuestEntry>;
  var i: int;

  entries = thePlayer.journal_quest_entries;

  for (i = 0; i < entries.Size(); i += 1) {
    if (entries[i].unique_tag == tag) {
      quest_entry = entries[i];
      
      return true;
    }
  }

  return false;
}

/**
 * Returns whether a quest with this unique tag exists
 */
function SU_doesQuestWithUniqueTagExist(tag: name): bool {
  var entries: array<SU_JournalQuestEntry>;
  var i: int;

  entries = thePlayer.journal_quest_entries;

  for (i = 0; i < entries.Size(); i += 1) {
    if (entries[i].unique_tag == tag) {
      return true;
    }
  }

  return false;
}

function SU_bootstrapQuestEntries(player: CR4Player) {
  var i: int;

  LogChannel('SU', "bootstrapping " + player.journal_quest_entries.Size() + " quest entries");

  for (i = 0; i < player.journal_quest_entries.Size(); i += 1) {
    if (player.journal_quest_entries[i].is_tracked) {
      LogChannel('SU', "bootstrapping " + player.journal_quest_entries[i].tag);
      player.journal_quest_entries[i].bootstrap();
    }
  }
}

function SU_getFirstTrackedQuest(out quest_entry: SU_JournalQuestEntry): bool {
  var entries: array<SU_JournalQuestEntry>;
  var i: int;

  entries = thePlayer.journal_quest_entries;

  for (i = 0; i < entries.Size(); i += 1) {
    if (entries[i].is_tracked) {
      quest_entry = entries[i];
      
      return true;
    }
  }

  return false;
}