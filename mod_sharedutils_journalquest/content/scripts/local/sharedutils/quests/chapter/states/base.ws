
/**
 * this base state is made to be extend to gain access to helper functions
 */
state BaseChapter in SU_JournalQuestChapter {

  /**
   * list of possible regions:
   *  - no_mans_land
   *  - skellige
   *  - bob
   *  - prolog_village
   *  - kaer_morhen
   */
  function getCurrentRegion(): string {
    var region: string;

    region = AreaTypeToName(theGame.GetCommonMapManager().GetCurrentArea());

    if (region == "novigrad") {
      return "no_mans_land";
    }

    if (region == "prolog_village_winter") {
      return "prolog_village";
    }

    return region;
  }
  
  /**
   * list of available regions:
   *  - no_mans_land
   *  - skellige
   *  - bob
   *  - prolog_village
   *  - kaer_morhen
   */
  function isPlayerInRegion(region: string): bool {
    return this.getCurrentRegion() == region;
  }

  /**
   * latent function that will sleep until the player reaches the position and
   * is in the supplied radius.
   */
  latent function waitForPlayerToReachPoint(position: Vector, radius: float) {
    var distance_from_player: float;
    var should_cancel: bool;

    // squared radius to save performances by using VecDistanceSquared
    radius *= radius;
    distance_from_player = VecDistanceSquared2D(thePlayer.GetWorldPosition(), position);

    while (distance_from_player > radius) {
      SleepOneFrame();

      should_cancel = this.waitForPlayerToReachPoint_action();
      if (should_cancel) {
        break;
      };

      distance_from_player = VecDistanceSquared2D(thePlayer.GetWorldPosition(), position);
    }
  }

  /**
   * override the function if necessary. It is called every iteration of 
   * this::waitForPlayerToReachPoint()
   */
  latent function waitForPlayerToReachPoint_action(): bool { return false; }

  /**
   * this function finds any creature from the supplied list that is outside the
   * radius at the given position, and if it is, teleports it back in the radius
   */
  function keepCreaturesOnPoint(position: Vector, radius: float, entities: array<CEntity>) {
    var distance_from_point: float;
    var old_position: Vector;
    var new_position: Vector;
    var i: int;

    for (i = 0; i < entities.Size(); i += 1) {
      old_position = entities[i].GetWorldPosition();

      distance_from_point = VecDistanceSquared(
        old_position,
        position
      );

      if (distance_from_point > radius) {
        new_position = VecInterpolate(
          old_position,
          position,
          1 / radius
        );

        this.groundPosition(new_position);

        if (new_position.Z < old_position.Z) {
          new_position.Z = old_position.Z;
        }

        entities[i].Teleport(new_position);
      }
    }
  }

  /**
   * this function returns if all the supplied entities are dead
   */
  public function areAllEntitiesDead(entities: array<CEntity>): bool {
    var i: int;

    for (i = 0; i < entities.Size(); i += 1) {
      if (((CActor)entities[i]).GetHealthPercents() >= 0.01) {
        return false;
      }
    }

    return true;
  }

  /**
   * corrects the Z position of the supplied vector
   */
  function groundPosition(out position : Vector) {
    var world : CWorld;
    var z : float;

    world = theGame.GetWorld();

    if (world.NavigationComputeZ(position, position.Z - 128, position.Z + 128, z)) {
      position.Z = z;
    }
    else if (world.PhysicsCorrectZ(position, z)) {
      position.Z = z;
    }
  }

  /**
   * latent function that loops until the player interacted with the given
   * entity.
   */
  latent function waitUntilInteraction(entity: CPeristentEntity) {
    var listener: SU_StoreIfInteractedWith;

    listener = new SU_StoreIfInteractedWith in entity;

    entity.addInteractionEventListener(listener);

    listener.waitUntilActivated();
  }

  /**
   * helper function that randomly spawns a random number of the supplied entity
   * in the supplied area.
   * Useful for creating clues, putting blood on the ground, etc...
   */
  latent function randomlySpawnEntityInArea(template_path: string, position: Vector, radius: float, max_count: int, optional min_count: int): array<CEntity> {
    var template: CEntityTemplate;
    var current_position: Vector;
    var output: array<CEntity>;
    var new_entity: CEntity;
    var i: int;
    
    template = (CEntityTemplate)LoadResourceAsync(template_path, true);
    max_count = RandRange(max_count, min_count);

    for (i = 0; i < max_count; i += 1) {
      current_position = position 
        + VecRingRand(0, radius);

      this.groundPosition(current_position);

      new_entity = theGame.CreateEntity(
        template,
        current_position,
        VecToRotation(VecRingRand(1, 2))
      );

      output.PushBack(new_entity);
    }

    return output;
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