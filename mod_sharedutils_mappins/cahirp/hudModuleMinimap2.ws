@context(
  define("mod.sharedutils.mappins")
  file("game/gui/hud/modules/hudModuleMinimap2.ws")
  at(class CR4HudModuleMinimap2)
)

@insert(
  at(OnConfigUI)
  at(if (hud))
  below(hud.UpdateHudConfig('Minimap2Module', true))
)
// sharedutils - mappins - BEGIN
SU_updateMinimapPins();
// sharedutils - mappins - END