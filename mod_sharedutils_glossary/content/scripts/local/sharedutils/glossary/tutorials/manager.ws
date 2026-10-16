class SU_GlossaryTutorialManager {
  // This snapshot supplies the displayed entries to selection and image handlers
  var entries: array<SU_GlossaryTutorialEntry>;

  // Remember read IDs across list rebuilds for this session
  private var read_entry_ids: array<name>;

  var populating_menu: CR4GlossaryTutorialsMenu;
  var list_published: bool;

  private function isStringValid(value: string): bool {
    return value != "";
  }

  private function isTagValid(tag: name): bool {
    return tag != '';
  }

  private function isEntryValid(item: SU_GlossaryTutorialEntry): bool {
    if (!item) {
      return false;
		}

    return this.isTagValid(item.entry_unique_id)
      && this.isTagValid(item.drop_down_tag)
      && this.isStringValid(item.getTitle())
      && this.isStringValid(item.drop_down_label);
  }

  private function indexOfEntry(tag: name): int {
    var i: int;

    if (!this.isTagValid(tag)) {
      return -1;
    }

    for (i = 0; i < this.entries.Size(); i += 1) {
      if (this.entries[i] && this.entries[i].entry_unique_id == tag) {
        return i;
      }
    }

    return -1;
  }

  private function setEntryAt(index: int, item: SU_GlossaryTutorialEntry): bool {
    if (index < 0 || index >= this.entries.Size()) {
      return false;
    }

    this.entries[index] = item;
    return true;
  }

  public function getEntry(tag: name): SU_GlossaryTutorialEntry {
    var index: int;

    index = this.indexOfEntry(tag);
    if (index < 0) {
      return NULL;
    }

    return this.entries[index];
  }

  public function hasEntry(tag: name): bool {
    return this.indexOfEntry(tag) > -1;
  }

  // Collect a fresh list on each rebuild. Duplicate IDs retain their position,
  // with the last contribution supplying the displayed entry.
  public function populateEntries(): void {
    var collected_entries: array<SU_GlossaryTutorialEntry>;
    var su_entry: SU_GlossaryTutorialEntry;
    var i: int;

    SU_populateTutorialEntries(collected_entries);
    this.entries.Clear();

    for (i = 0; i < collected_entries.Size(); i += 1) {
      su_entry = collected_entries[i];

      if (!this.isEntryValid(su_entry)) {
        continue;
      }

      if (this.read_entry_ids.Contains(su_entry.entry_unique_id)) {
        su_entry.is_new = false;
      }

      if (!this.setEntryAt(this.indexOfEntry(su_entry.entry_unique_id), su_entry)) {
        this.entries.PushBack(su_entry);
      }
    }
  }

  public function markEntryRead(tag: name): bool {
    var su_entry: SU_GlossaryTutorialEntry;

    su_entry = this.getEntry(tag);
    if (!su_entry) {
      return false;
    }

    su_entry.is_new = false;
    if (!this.read_entry_ids.Contains(tag)) {
      this.read_entry_ids.PushBack(tag);
    }

    return true;
  }
}
