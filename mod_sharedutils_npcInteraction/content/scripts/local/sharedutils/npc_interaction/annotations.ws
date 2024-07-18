@addField(CPeristentEntity)
saved var onInteractionEventListeners: array<SU_InteractionEventListener>;

@addField(CR4Player)
var sharedutilsNpcInteractionGlobalEventListener: SU_NpcInteraction_GlobalEventHandler;

@addMethod(CR4Player)
function SU_NpcInteraction_getGlobalEventListener(): SU_NpcInteraction_GlobalEventHandler {
  if (!this.sharedutilsNpcInteractionGlobalEventListener) {
    this.sharedutilsNpcInteractionGlobalEventListener = (new SU_NpcInteraction_GlobalEventHandler in this)
      .init();
  }

  return this.sharedutilsNpcInteractionGlobalEventListener;
}

@wrapMethod(CInteractionComponent)
function OnInteraction(actionName: string,activator: CEntity) {
  if (SU_NpcInteraction_runAllInteractionListeners(actionName, activator, this.GetEntity())) {
    return wrappedMethod(actionName, activator);
  }

  return false;
}

@addMethod(CPeristentEntity)
function addInteractionEventListener(event_listener: SU_InteractionEventListener) {
  this.onInteractionEventListeners.PushBack(event_listener);
}