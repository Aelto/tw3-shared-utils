
abstract class SUOL_Predicate {
  /// This function dictates whether the oneliner should receive the change
  /// (deletion,update,find) implied by the function receiving the predicate.
  ///
  /// if it returns false then nothing happens for this oneliner
  public function filter(oneliner: SU_Oneliner, index: int, manager: SUOL_Manager): bool;

  /// Called on every oneliner whose `filter` returned true. Can be used to transform
  /// the oneliner before final action. Be aware that any addition or removal of
  /// oneliners in this function might break the predicate runner in unexpected
  /// ways. Only mutate or replace (as long as it has the same ID) the received
  /// oneliner but never add/remove ones.
  public function transform(oneliner: SU_Oneliner, index: int, manager: SUOL_Manager):  {
    return oneliner;
  }
}

class SUOL_PredicateTagStartsWith {
  var prefix: string;

  public function init(prefix: string): SUOL_PredicateTagStartsWith {
    this.prefix = prefix;
    
    return this;
  }

  public function filter(oneliner: SU_Oneliner, index: int, manager: SUOL_Manager): bool {
    return StrStartsWith(oneliner.tag, this.prefix);
  }
}

class SUOL_PredicateTagEndsWith {
  var suffix: string;

  public function init(suffix: string): SUOL_PredicateTagEndsWith {
    this.suffix = suffix;
    
    return this;
  }

  public function filter(oneliner: SU_Oneliner, index: int, manager: SUOL_Manager): bool {
    return StrEndsWith(oneliner.tag, this.suffix);
  }
}

class SUOL_PredicateTag {
  var tag: string;

  public function init(tag: string): SUOL_PredicateTag {
    this.tag = tag;

    return this;
  }

  public function filter(oneliner: SU_Oneliner, index: int, manager: SUOL_Manager): bool {
    return oneliner.tag === this.suffix;
  }
}