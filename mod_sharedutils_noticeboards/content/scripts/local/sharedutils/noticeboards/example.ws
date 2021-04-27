
/**
 * a basic example that shows how to add a custom injector to a nearby
 * noticeboard.
 */
exec function suadderrandinjector() {
  var entities: array<CGameplayEntity>;
  var board: W3NoticeBoard;

  FindGameplayEntitiesInRange(
    entities,
    thePlayer,
    10, // range, 
    1, // max results
    , // tag: optional value
    FLAG_ExcludePlayer,
    , // optional value
    'W3NoticeBoard'
  );

  if (entities.Size() < 1) {
    theGame
    .GetGuiManager()
    .ShowNotification("Could not find any noticeboard nearby");
  }

  board = (W3NoticeBoard)entities[0];

  if (board) {
    board.addErrandInjector(new SU_ErrandInjectorExample in board);

    theGame
    .GetGuiManager()
    .ShowNotification("added example injector");
  }
  else {
    theGame
    .GetGuiManager()
    .ShowNotification("Could not find any noticeboard nearby (cast fail)");
  }
}

class SU_ErrandInjectorExample extends SU_ErrandInjector {
  public function run(board: W3NoticeBoard) {
    SU_replaceFlawWithErrand(board, "hello world!");
  }

  public function accepted(board: W3NoticeBoard, errand_name: string) {
    theGame
    .GetGuiManager()
    .ShowNotification("accepted errand with name = " + errand_name);

    this.logErrandWithName(board, errand_name);
  }

  private function logErrandWithName(board: W3NoticeBoard, errand_name: string) {
    var i: int;

    for (i = 0; i < board.activeErrands.Size(); i += 1) {
      if (board.activeErrands[i].errandStringKey == errand_name) {
        LogChannel('SUTEST', "accepted errand with name = " + errand_name);
        LogChannel('SUTEST', "accepted errand with title = " + GetLocStringByKey(errand_name));
        LogChannel('SUTEST', "accepted errand with body = " + GetLocStringByKey(errand_name + "_text"));
      }
    }
  }
}