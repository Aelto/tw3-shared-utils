@context(
  define("mod.sharedutils.npcInteraction")
  file("engine/component.ws")
  at(class CComponent)
)

@insert(
  at(event OnInteraction)
  above(if)
)
// sharedutils - npcInteraction - BEGIN
if (!SU_NpcInteraction_runAllInteractionListeners(actionName, activator, this.GetEntity())) {
  return false;
}
// sharedutils - npcInteraction - END