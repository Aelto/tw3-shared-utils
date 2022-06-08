
class SU_HashMap {
  private var buckets: array<SU_HashMapBucket>;

  private var buckets_count: int;

  private var items_count: int;

  public function init(): SU_HashMap {
    var i: int;

    this.buckets.Grow(29); // prime number

    for (i = 0; i < this.buckets.Size(); i += 1) {
      this.buckets[i] = new SU_HashMapBucket in this;
    }

    return this;
  }

  /**
   *
   */
  public function insert(key: int, value: SU_HashMapValue) {
    var bucket: SU_HashMapBucket;
    var hash: int;

    hash = this.getHash(key);
    bucket = this.buckets[hash];

    value.key = key;
    if (bucket.insert(value)) {
      items_count += 1;
    }

    if (this.getLoadFactor() > 0.9) {
      this.allocateNewBuckets();
    }
  }

  /**
   *
   */
  public function get(key: int): SU_HashMapValue {
    var bucket: SU_HashMapBucket;
    var hash: int;

    hash = this.getHash(key);
    bucket = this.buckets[hash];

    return bucket.get(key);
  }

  /**
   * A hashing function with poor distribution
   */ 
  private function getHash(key: int): int {
    // 4289 is a prime number
    return (key * 4289) % this.buckets_count;
  }

  private function getLoadFactor(): float {
    return this.items_count / this.buckets_count;
  }

  /**
   *
   */
  private function allocateNewBuckets() {
    var all_items: array<SU_HashMapValue>;
    var current_item: SU_HashMapValue;
    var i: int;
    var k: int;

    // 1.
    // start by allocating the new buckets
    for (i = 0; i < 9; i += 1) {
      this.buckets.PushBack(new SU_HashMapBucket in this);
    }

    this.buckets_count = this.buckets.Size();

    // 2.
    // re-order the items from all the buckets
    for (i = 0; i < this.buckets_count; i += 1) {
      this.buckets[i].extractValues(all_items);
    }

    for (i = 0; i < all_items.Size(); i += 1) {
      current_item = all_items[i];

      this.insert(current_item.key, current_item);
    }
  }
}

class SU_HashMapBucket {
  public var items: array<SU_HashMapValue>;

  /**
   * return true if the insertion resulted in a new pushed item in the bucket
   * return false if the insertion resulted in a replaced value
   */
  public function insert(value: SU_HashMapValue): bool {
    var i: int;

    for (i = 0; i < this.items.Size(); i += 1) {
      if (this.items[i].key == value.key) {
        this.items[i] = value;

        return false;
      }
    }

    this.items.PushBack(value);

    return true;
  }

  public function get(key: int): SU_HashMapValue {
    var i: int;

    for (i = 0; i < this.items.Size(); i += 1) {
      if (this.items[i].key == key) {
        return this.items[i];
      }
    }

    return new SU_HashMapValueNone in this;
  }

  public function remove(value: SU_HashMapValue) {
    this.items.Remove(value);
  }

  public function extractValues(out arr: array<SU_HashMapValue>) {
    var initial_size: int;
    var new_size: int;
    var i: int;

    if (this.items.Size() <= 0) {
      return;
    }

    initial_size = arr.Size();
    new_size = arr.Grow(this.items.Size());

    for (i = initial_size; i < new_size; i += 1) {
      arr[i] = this.items[i - initial_size];
    }

    this.items.Clear();
  }
}

abstract class SU_HashMapValue {
  public var key: int;

  public function isSome(): bool {
    return true;
  }
}

class SU_HashMapValueNone extends SU_HashMapValue {
  public function isSome(): bool {
    return false;
  }
}

class SU_HashMapValueString extends SU_HashMapValue {
  public var value: string;
}

function hm_fromString(str: string): SU_HashMapValueString {
  var value: SU_HashMapValueString;

  value = new SU_HashMapValueString in thePlayer;
  value.value = str;

  return value;
}

exec function suhashmap() {
  var result: SU_HashMapValueString;
  var map: SU_HashMap;

  map = (new SU_HashMap in thePlayer).init();
  map.insert(234, hm_fromString("hello"));
  map.insert(346, hm_fromString("world!"));
  map.insert(23490, hm_fromString("foo"));
  map.insert(9045, hm_fromString("bar"));
  map.insert(9045, hm_fromString("foobar"));

  result = (SU_HashMapValueString)map.get(23490);

  if (result) {
    NLOG(result.value);
  }

  result = (SU_HashMapValueString)map.get(9045);

  if (result) {
    NLOG(result.value);
  }
}