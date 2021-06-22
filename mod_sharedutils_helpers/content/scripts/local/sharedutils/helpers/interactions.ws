
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