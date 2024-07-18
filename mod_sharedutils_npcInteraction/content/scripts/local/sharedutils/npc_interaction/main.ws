
/**
 * This is the abstract class for the event listener. If you want to add an event
 * listener to an NPC in order to run your custom code, create a new class that
 * extends `SU_InteractionEventListener` and override the `run` method.
 */
abstract class SU_InteractionEventListener {

  /**
   * The tag is not used by the code, but it could be useful in case you want to
   * verify if an NPC already has an event listener with a specific tag.
   * It's your only way to identify the event listeners without doing a full
   * bitwise comparison.
   */
  public var tag: string;
  default tag = "None";

  /**
   * This method is run whenever the NPC had his interaction event triggered.
   * You get as parameters the actionName as well as the activator, those two
   * parameters are the default parameters the CNewNPC::OnInteraction event has
   * and then this method has a third parameter that is the NPC the player
   * interacted with.
   */
  public function run(actionName : string, activator : CEntity, receptor: CPeristentEntity): bool {
    /**
     * The return value here dictactes if the CNewNPC::OnInteraction event should
     * continue after your code or if it should end.
     * A return value of `false` will tell the event to stop there and not go
     * any further.
     */
    return true;
  }

}

/**
 * This statemachine is stored in the InputManager class for easy access via
 * `theInput.global_event_handler`. Every time an interaction event is sent,
 * even if the entity has no event listener from sharedutils it will loop
 * through all the global event listeners mods could have added to the game.
 *
 * The global event handler uses a special trick to ensure compile-time checks
 * and avoid the users of sharedutils to use a mod like bootstrap to inject
 * the event listeners. Read the comments in the class to understand how it
 * works.
 *
 * Refer to the examples in the example folder of the mod to see how to make a
 * global event listener.
 */
statemachine class SU_NpcInteraction_GlobalEventHandler {
  /**
   * A queue of states to process, read the `onInteraction` comments to learn
   * more.
   *
   * NOTE: with the current implementation of the class, this is a FILO queue.
   */
  protected var states_to_process: array<name>;

  /**
   * these three attributes are used to store the current action name, activator
   * and receptor for the interaction event. Since the event listeners are
   * states we cannot pass them parameters like regular functions, we are forced
   * to do it like this.
   */
  var actionName: string;
  var activator: CEntity;
  var receptor: CEntity;

  public function init(): SU_NpcInteraction_GlobalEventHandler {
    this.GotoState('Empty');

    return this;
  }

  public function onInteraction(actionName : string, activator : CEntity, receptor: CEntity) {
    var states_to_process: array<name>;
    var i: int;

    this.actionName = actionName;
    this.activator = activator;
    this.receptor = receptor;

    // This is the special trick we talked about in the comment above. To get a
    // list of state names dynamically at runtime is to use fake items that use
    // a custom tag. There items have no use but the function returns an array
    // of names, which happens to be the names of the states we want to run
    // through.
    //
    // This solution is perfect for what we want, it offers a way to add event
    // listeners without needing to use a mod like bootstrap or to add a script
    // in the Player class to inject the listener. Since we are adding states
    // to the statemachine it is also checked at compile time, if two states,
    // aka global event listeners, share the same name then we will get a
    // compilation issue.
    states_to_process = theGame.GetDefinitionsManager()
      .GetItemsWithTag('SU_NpcInteraction_GlobalEventListener');

    // we now push the state names to the queue
    for (i = 0; i < states_to_process.Size(); i += 1) {
      this.states_to_process.PushBack(states_to_process[i]);
    }

    if (this.GetCurrentStateName() == 'Empty') {
      this.GotoState('Waiting');
    }
  }
}

/**
 * The state all global event listeners should extend.
 */
state GlobalEventListener in SU_NpcInteraction_GlobalEventHandler {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
  }

  public function finish() {
    parent.GotoState('Waiting');
  }
}

state Empty in SU_NpcInteraction_GlobalEventHandler {}
state Waiting in SU_NpcInteraction_GlobalEventHandler {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    this.Waiting_main(previous_state_name);
  }

  entry function Waiting_main(previous_state_name: name) {
    this.startProcessingLastState();
  }

  function startProcessingLastState() {
    var last_state: name;
    
    if (parent.states_to_process.Size() <= 0) {
      parent.GotoState('Empty');

      return;
    }

    last_state = parent.states_to_process.PopBack();
    parent.GotoState(last_state);
  }
}

function SU_NpcInteraction_runAllInteractionListeners(actionName: string, activator: CEntity, receptor: CEntity): bool {
  var current_event_listener: SU_InteractionEventListener;
  var handler: SU_NpcInteraction_GlobalEventHandler;
  var persistent_entity: CPeristentEntity;
  var should_event_continue: bool;
  var player_input: CPlayerInput;
  var i: int;

  handler = thePlayer.SU_NpcInteraction_getGlobalEventListener();

  handler.onInteraction(
    actionName,
    activator,
    receptor
  );

  should_event_continue = true;

  if ((CPeristentEntity)receptor) {
    persistent_entity = (CPeristentEntity)receptor;

    for (i = 0; i < persistent_entity.onInteractionEventListeners.Size(); i += 1) {
      current_event_listener = persistent_entity.onInteractionEventListeners[i];

      should_event_continue = should_event_continue && current_event_listener.run(
        actionName,
        activator,
        persistent_entity
      );
    }
  }


  return should_event_continue;
}

function SU_NpcInteraction_hasEventListenerWithTag(npc: CPeristentEntity, tag: string): bool {
  var current_event_listener: SU_InteractionEventListener;
  var i: int;

  for (i = 0; i < npc.onInteractionEventListeners.Size(); i += 1) {
    current_event_listener = npc.onInteractionEventListeners[i];
    
    if (current_event_listener.tag == tag) {
      return true;
    }
  }

  return false;
}

function SU_removeInteractionEventListenerByTag(npc: CPeristentEntity, tag: string) {
  var current_event_listener: SU_InteractionEventListener;
  var i: int;
  
  for (i = 0; i < npc.onInteractionEventListeners.Size(); i += 1) {
    current_event_listener = npc.onInteractionEventListeners[i];

    if (current_event_listener.tag != tag) {
      continue;
    }

    if (i == npc.onInteractionEventListeners.Size() - 1) {
      npc.onInteractionEventListeners.PopBack();
      continue;
    }

    npc.onInteractionEventListeners.Erase(i);
    i -= 1;
  }
}


/**
 * A really basic SU_InteractionEventListener that sets a boolean to true when
 * the player has interacted with the component, then removes itself from the
 * list.
 */
class SU_StoreIfInteractedWith extends SU_InteractionEventListener {

  /**
   * The tag we will use to identify this kind of event listener
   */
  default tag = "SU_StoreIfInteractedWith";

  public var was_activated: bool;

  /**
   * Override the run method to run our custom code.
   */
  public function run(actionName : string, activator : CEntity, receptor: CPeristentEntity): bool {
    this.was_activated = true;

    SU_removeInteractionEventListenerByTag(receptor, this.tag);

    /**
     * We still want the dialogue to play after the interaction, so we'll return
     * true no matter what.
     */
    return true;
  }

  public latent function waitUntilActivated() {
    while (!this.was_activated) {
      SleepOneFrame();
    }
  }

}

/**
 * latent function that loops until the player interacted with the given
 * entity.
 */
latent function SUH_waitUntilInteraction(entity: CPeristentEntity) {
  var listener: SU_StoreIfInteractedWith;

  listener = new SU_StoreIfInteractedWith in entity;

  entity.addInteractionEventListener(listener);

  listener.waitUntilActivated();
}