
class SU_NotifyOnInteraction extends SU_InteractionEventListener {

  /**
   * The tag we will use to identify this kind of event listener
   */
  default tag = "SU_NotifyOnInteraction";

  /**
   * Override the run method to run our custom code.
   */
  public function run(actionName : string, activator : CEntity, receptor: CPeristentEntity): bool {
    theGame
      .GetGuiManager()
      .ShowNotification("Player interaction with this NPC, action name = " + actionName);

    /**
     * We still want the dialogue to play after the interaction, so we'll return
     * true no matter what.
     */
    return true;
  }

}

/**
 * This function add our own event listener to all surrounding NPCs
 */
exec function SU_NpcInteraction_addNotifyEventToNearbyNPCs() {
  var entities: array<CGameplayEntity>;
  var i: int;

  FindGameplayEntitiesInRange(
    entities,
    thePlayer,
    10, // the range: 10 units around the player
    10, // the max number of results: 10 NPCs
    ,
    FLAG_ExcludePlayer,
    ,
    'CNewNPC' // we want entities from the CNewNPC class only
  );

  theGame
      .GetGuiManager()
      .ShowNotification("adding notify event to " + entities.Size() + " NPCs");

  for (i = 0; i < entities.Size(); i += 1) {
    // the NPC already has an event like this, so we skip it.
    if (SU_NpcInteraction_hasEventListenerWithTag((CNewNPC)entities[i], "SU_NotifyOnInteraction")) {
      continue;
    }

    ((CNewNPC)entities[i]).addInteractionEventListener(new SU_NotifyOnInteraction in entities[i]);
  }
}