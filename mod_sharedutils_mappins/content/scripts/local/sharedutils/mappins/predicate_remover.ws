
function SU_removeCustomPinByPredicate(predicate_runner: SU_PredicateInterfaceRemovePin) {
  var i: int;
  var current_pin: SU_MapPin;
  var last_pin: SU_MapPin;
  
  for (i = 0; i < thePlayer.customMapPins.Size(); i += 1) {
    current_pin = thePlayer.customMapPins[i];

    if (!predicate_runner.predicate(current_pin)) {
      continue;
    }

    if (i == thePlayer.customMapPins.Size() - 1) {
      thePlayer.customMapPins.PopBack();
      SU_removeMinimapPin(i);
      continue;
    }

    thePlayer.customMapPins.Erase(i);
    SU_removeMinimapPin(i);
    i -= 1;
  }
}

/**
 * This is an abstract class that acts as an interface for any function that
 * requires some sort of predicate. Because the language doesn't support lambdas
 * nor function pointers, this is the only viable solution.
 *
 * To use it, extend the class and override the right methods according to your
 * needs.
 */
abstract class SU_PredicateInterfaceRemovePin {
  /**
   * Override the method and return true to perform the action that is described
   * by the function asking for a PredicateInterface
   */
  function predicate(pin: SU_MapPin): bool {
    return false;
  }
}

/**
 * This is a predicate interface i felt could be useful so it comes prebuilt in
 * the utility
 */
class SU_CustomPinRemoverPredicateTagIncludesSubstring extends SU_PredicateInterfaceRemovePin {
  var substring: String;

  function predicate(pin: SU_MapPin): bool {
    return StrContains(pin.tag, this.substring);
  }
}

class SU_CustomPinRemoverPredicateTagStartsWith extends SU_PredicateInterfaceRemovePin {
  var prefix: String;

  function predicate(pin: SU_MapPin): bool {
    return StrContains(pin.tag, this.prefix);
  }

  function init(prefix: String): SU_CustomPinRemoverPredicateTagStartsWith {
    this.prefix = prefix;

    return this;
  }
}