
/**
 * This is the abstract class that you can add to any noticeboard and that will
 * allow you do inject custom errands to it.
 */
abstract class SU_ErrandInjector {
  /**
   * This isn't used by the code but only for you to easily identify your
   * injectors.
   */
  var tag: string; 

  /**
   * This method is run every time the game loads the errands for a noticeboard,
   * it runs AFTER the vanilla errands are added and so its goal is to replace
   * what CDPR calls flaws, basically useless notices that don't lead to any
   * quest.
   */
  function run(out board: W3NoticeBoard) {

  }

  /**
   * This method is run for every errand picked by the player, not only the
   * errand you injected. It's up to you to filter the results.
   */
  function accepted(out board: W3NoticeBoard, errand_name: string) {
  }

}

/**
 * use this function to replace a flaw (a fluff notice) with a real notice
 * NOTE: the errand_string is a LocStringKey that is used for the title, and
 * then the vanilla game adds `_text` after the key to get the body.
 * Example:
 *    errand_string = fluff_fat_catch_inn_noticeboard_10
 *    title = GetLocStringByKey(errand_name)
 *    body = GetLocStringByKey(errand_name + "_text")
 * This is what the game does and we have no control over it.
 */
function SU_replaceFlawWithErrand(out board: W3NoticeBoard, errand_string: string): bool {
  var current_errand: ErrandDetailsList;
  var i: int;

  // 1.
  // first we verify it doesn't already exist.
  for (i = 0; i < board.activeErrands.Size(); i += 1) {
    current_errand = board.activeErrands[i];

    // 1.1
    // a flaw with the same name already exists, so we stop now and return false
    // to notify nothing was added here
    if (current_errand.errandStringKey == errand_string) {
      return false;
    }
  }

  // 2.
  // looping through the list to see if there is a flaw we can replace
  for (i = 0; i < board.activeErrands.Size(); i += 1) {
    current_errand = board.activeErrands[i];

    // 2.1
    // it is a flaw, we replace it with our errand
    if (current_errand.newQuestFact == "flaw") {
      board.activeErrands[i].errandStringKey = errand_string;
      board.activeErrands[i].newQuestFact = "injected_errand";

      return true;
    }
  }

  return false;
}

function SU_runAllErrandInjectors(board: W3NoticeBoard) {
  var injector: SU_ErrandInjector;
  var i: int;

  // LogChannel('SUTEST', "running " + board.errandInjectors.Size() + " injectors");

  for (i = 0; i < board.errandInjectors.Size(); i += 1) {
    injector = board.errandInjectors[i];

    injector.run(board);
  }
}

function SU_hasErrandInjectorWithTag(board: W3NoticeBoard, tag: String): bool {
  var i: int;
  var current_injector: SU_ErrandInjector;
  
  for (i = 0; i < board.errandInjectors.Size(); i += 1) {
    current_injector = board.errandInjectors[i];

    if (current_injector.tag == tag) {
      return true;
    }
  }

  return false;
}

function SU_removeErrandInjectorByTag(board: W3NoticeBoard, tag: String) {
  var i: int;
  var current_injector: SU_ErrandInjector;
  
  for (i = 0; i < board.errandInjectors.Size(); i += 1) {
    current_injector = board.errandInjectors[i];

    if (current_injector.tag != tag) {
      continue;
    }

    if (i == board.errandInjectors.Size() - 1) {
      board.errandInjectors.PopBack();
      continue;
    }

    board.errandInjectors.Erase(i);
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
abstract class SU_PredicateInterfaceRemoveErrandInjector {
  /**
   * Override the method and return true to perform the action that is described
   * by the function asking for a PredicateInterface
   */
  function predicate(injector: SU_ErrandInjector): bool {
    return false;
  }
}

/**
 * This is a predicate interface i felt could be useful so it comes prebuilt in
 * the utility
 */
class SU_ErrandInjectorRemoverPredicateTagIncludesSubstring extends SU_PredicateInterfaceRemoveErrandInjector {
  var substring: String;

  function predicate(injector: SU_ErrandInjector): bool {
    return StrContains(injector.tag, this.substring);
  }
}