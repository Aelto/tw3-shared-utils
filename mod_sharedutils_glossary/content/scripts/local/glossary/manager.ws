
class SU_GlossaryManager extends SU_StorageItem {
  default tag = "SU_GlossaryManager";

  var entries: array<SU_GlossaryEntry>;

  private function isTitleValid(title: string): bool {
    return title != "";
  }

  private function isTagValid(tag: name): bool {
    return tag != '';
  }
  
  private function isEntryValid(item: SU_GlossaryEntry): bool {
    if (!item) {
      return false;
    }

    return this.isTitleValid(item.getTitle()) && this.isTagValid(item.getTag());
  }

  public function getEntry(tag: name): SU_GlossaryEntry {
    var i: int;

    if (!this.isTagValid(tag)) {
      return NULL;
    }

    for (i = 0; i < this.entries.Size(); i += 1) {
      if (this.entries[i].getTag() == tag) {
        return this.entries[i];
      }
    }

    return NULL;
  }

  public function indexOfEntry(tag: name): int {
    var i: int;

    if (!this.isTagValid(tag)) {
      return -1;
    }

    for (i = 0; i < this.entries.Size(); i += 1) {
      if (this.entries[i].getTag() == tag) {
        return i;
      }
    }

    return -1;
  }

  public function hasEntry(tag: name): bool {
    return this.indexOfEntry(tag) >= 0;
  }

  public function setEntry(item: SU_GlossaryEntry): bool {
    var i: int;

    if (!this.isEntryValid(item)) {
      return false;
    }

    // if an entry with the same title already exists, replace it:
    if (!this.setEntryAt(this.indexOfEntry(item.getTag()), item)) {
      // otherwise push it to the array of entries:
      this.entries.PushBack(item);  
    }

    return true;
  }

  public function removeEntry(item: SU_GlossaryEntry) {
    this.entries.Remove(item);
  }

  public function removeEntriesByPrefix(tag_prefix: name) {
    var i: int;
	
	for (i = 0; i < this.entries.Size(); i += 1) {
		if (StrStartsWith(NameToString(this.entries[i].getTag()), tag_prefix)) {
			removeEntry(this.entries[i]);
		}
	}
  }

  public function removeEntriesBySegment(tag_segment: name) {
    var i: int;
	
	for (i = 0; i < this.entries.Size(); i += 1) {
		if (StrContains(NameToString(this.entries[i].getTag()), tag_segment)) {
			removeEntry(this.entries[i]);
		}
	}
  }
  
  private function setEntryAt(index: int, item: SU_GlossaryEntry): bool {
    // out of bound
    if (index < 0 || index >= this.entries.Size()) {
      return false;
    }

    if (!this.isEntryValid(item)) {
      return false;
    }

    this.entries[index] = item;

    return true;
  }
}
