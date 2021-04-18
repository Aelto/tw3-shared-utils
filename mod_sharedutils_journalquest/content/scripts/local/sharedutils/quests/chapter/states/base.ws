
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
    distance_from_player = VecDistanceSquared(thePlayer.GetWorldPosition(), position);

    while (distance_from_player > radius) {
      Sleep(1);

      LogChannel('SU', "waitForPlayerToReachPoint, distance = " + distance_from_player);

      // should_cancel = this.waitForPlayerToReachPoint_action();
      if (should_cancel) {
        break;
      };

      distance_from_player = VecDistanceSquared(thePlayer.GetWorldPosition(), position);
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
  distance_from_player = VecDistanceSquared(thePlayer.GetWorldPosition(), position);

  while (distance_from_player > radius) {
    Sleep(1);

    LogChannel('SU', "waitForPlayerToReachPoint, distance = " + distance_from_player);

    // should_cancel = this.waitForPlayerToReachPoint_action();
    if (should_cancel) {
      break;
    };

    distance_from_player = VecDistanceSquared(thePlayer.GetWorldPosition(), position);
  }
}