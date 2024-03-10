@context(
  define("mod.sharedutils.noticeboard")
  file("game/gameplay/board.ws")
  at(class W3NoticeBoard)
)

@insert(
  above(event OnSpawned)
)
// sharedutils - noticeboards - BEGIN
saved var errandInjectors: array<SU_ErrandInjector>;

public function addErrandInjector(injector: SU_ErrandInjector) {
  this.errandInjectors.PushBack(injector);
}
// sharedutils - noticeboards - END

@insert(
  at(function UpdateBoard)
  below(CheckIfEmpty)
)
// sharedutils - noticeboards - BEGIN
SU_runAllErrandInjectors(this);
// sharedutils - noticeboards - END

@insert(
  at(function AcceptNewQuest)
  above(stillDisplayed = 0)
)
// sharedutils - noticeboards - BEGIN
SU_notifyAcceptedErrandToInjectors(errandName, this);
// sharedutils - noticeboards - END