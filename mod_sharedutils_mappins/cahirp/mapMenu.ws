@context(
  define("mod.sharedutils.mappins")
  file("game/gui/menus/mapMenu.ws")
  at(class CR4MapMenu)
)

@insert(
  at(function UpdateUserMapPins)
  at(else)
  at(for)
  below(})
)
// sharedutils - mappins - BEGIN
SU_updateCustomMapPins(flashArray, GetMenuFlashValueStorage(), m_shownArea); 
// sharedutils - mappins - END

@insert(
  at(OnStaticMapPinUsed)
  below(manager	= theGame.GetCommonMapManager())
)
// sharedutils - mappins - BEGIN
if (SUMP_onPinUsed(pinTag, areaId)) {
  return true;
}
// sharedutils - mappins - END