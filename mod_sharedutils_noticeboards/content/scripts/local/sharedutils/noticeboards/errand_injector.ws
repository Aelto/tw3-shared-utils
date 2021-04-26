
/**
 * This is the abstract class that you can add to any noticeboard and that will
 * allow you do inject custom errands to it.
 */
abstract class SU_ErrandInjector {

  /**
   * This method is run every time the game loads the errands for a noticeboard,
   * it runs AFTER the vanilla errands are added and so its goal is to replace
   * what CDPR calls flaws, basically useless notices that don't lead to any
   * quest.
   */
  public function run(board: W3NoticeBoard) {

  }

  /**
   * This method is run for every errand picked by the player, not only the
   * errand you injected. It's up to you to filter the results.
   */
  public function accepted(errand_name: string) {
  }

}

/**
 * use this function to replace a flaw (a fluff notice) with a real notice
 */
function SU_replaceFlawWithErrand(board: W3NoticeBoard, errand_string: string): bool {
  var current_errand: ErrandDetailsList;
  var i: int;

  // looping through the list to see if there is a flaw we can replace
  for (i = 0; i < board.activeErrands.Size(); i += 1) {
    current_errand = board.activeErrands[i];

    // LogChannel('SUTEST', "errand quest fact = " + current_errand.newQuestFact + " string key = " + current_errand.errandStringKey);

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