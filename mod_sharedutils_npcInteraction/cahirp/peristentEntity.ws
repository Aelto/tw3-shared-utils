@context(
  define("mod.sharedutils.npcInteraction")
  file("engine/persistentEntity.ws")
  at(class CPeristentEntity)
)

@insert(
  above(event OnSpawned)
)
// sharedutils - npcInteraction - BEGIN
public saved var onInteractionEventListeners: array<SU_InteractionEventListener>;

public function addInteractionEventListener(event_listener: SU_InteractionEventListener) {
  this.onInteractionEventListeners.PushBack(event_listener);
}
// sharedutils - npcInteraction - END