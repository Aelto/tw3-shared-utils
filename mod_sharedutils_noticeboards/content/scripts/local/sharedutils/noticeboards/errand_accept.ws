
function SU_notifyAcceptedErrandToInjectors(errand_name: string, board: W3NoticeBoard): bool {
  var injector: SU_ErrandInjector;
  var i: int;

  for (i = 0; i < board.errandInjectors.Size(); i += 1) {
    injector = board.errandInjectors[i];

    injector.accepted(board, errand_name);
  }

  return i > 0;
}