
class SU_JournalQuestChapterObjective {
  /**
   * the unique value used to identify the objective among the other objectives
   */
  var tag: string;
  
  /**
   * used by the UI, it can be the same value as the tag, but with the name type
   */
  var unique_tag: name;

  /**
   * this is the string that will be displayed in the UI.
   */
  var label: string;

  /**
   * this list contains the mappins that will be displayed when the objective is
   * tracked.
   */
  var pins: array<SU_MapPin>;

  /**
   * an helper function that can be used to set a localized string as a label.
   * It returns `this` and is chainable, which is useful in case you want to
   * quickly initialize the class and set the localized label at the same time
   * without having to use a variable.
   */
  function setLocalizedLabel(key: string): SU_JournalQuestChapterObjective {
    this.label = GetLocStringByKey(key);

    return this;
  }

  /**
   * an helper function that can be used to set an unlocalized string as a label
   * It returns `this` and is chainable, which is useful in case you want to
   * quickly initialize the class and set the localized label at the same time
   * without having to use a variable.
   */
  function setLabel(label: string): SU_JournalQuestChapterObjective {
    this.label = label;

    return this;
  }

  function setTags(tags: name): SU_JournalQuestChapterObjective {
    this.tag = ""+tags;
    this.unique_tag = tags;

    return this;
  }

  /**
   * this function is an helper function you can chain to add pins to the
   * objective. It also edits the pin tag to make sure it's unique and does
   * not conflict with an already existing pin.
   * This is why it is recommended to add pins via this function and not
   * directly through the `this.pins` property.
   */
  public function addPin(pin: SU_MapPin): SU_JournalQuestChapterObjective {
    // edit the pin tag at insertion to make sure it has a unique tag that suits
    // the current objective.
    pin.tag = this.tag + "_" + pin.tag;

    this.pins.PushBack(pin);

    return this;
  }

  public function getFirstPin(): SU_MapPin {
    return this.pins[0];
  }

  /**
   * start tracking the objective and display all its pins
   */
  function track() {
    var i: int;

    for (i = 0; i < this.pins.Size(); i += 1) {
      thePlayer.addCustomPin(this.pins[i]);
    }
  }

  /**
   * stop tracking the objective and remove all its pins from the map.
   */
  function untrack() {
    var i: int;

    for (i = 0; i < this.pins.Size(); i += 1) {
      LogChannel('SU', "ChapterObjective::untrack() - remove pin with tag = " + this.pins[i].tag);
      SU_removeCustomPinByTag(this.pins[i].tag);
    }
  }
}