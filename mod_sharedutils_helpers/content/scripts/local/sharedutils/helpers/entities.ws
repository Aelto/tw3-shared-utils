function SUH_makeEntitiesTargetPlayer(entities: array<CEntity>) {
  var i: int;

  for (i = 0; i < entities.Size(); i += 1) {
    if (((CActor)entities[i]).GetTarget() != thePlayer && !((CActor)entities[i]).HasAttitudeTowards(thePlayer)) {
      ((CNewNPC)entities[i]).NoticeActor(thePlayer);
      ((CActor)entities[i]).SetAttitude(thePlayer, AIA_Hostile);
    }
  }
}

function SUH_getEntitiesInRange(position: Vector, radius: float): array<CEntity> {
  var gameplay_entities: array<CGameplayEntity>;
  var output: array<CEntity>;
  var entity: CEntity;
  var i: int;

  FindGameplayEntitiesInCylinder(gameplay_entities, position, radius, radius, 100,, FLAG_OnlyAliveActors + FLAG_ExcludePlayer,, 'CEntity');

  for (i = 0; i < gameplay_entities.Size(); i += 1) {
    entity = (CEntity)gameplay_entities[i];
    
    if (entity) {
      output.PushBack((CEntity)gameplay_entities[i]);
    }
  }

  return output;
}

function SUH_areAllEntitiesFarFromPlayer(entities: array<CEntity>): bool {
  var player_position: Vector;
  var i: int;

  player_position = thePlayer.GetWorldPosition();

  for (i = 0; i < entities.Size(); i += 1) {
    if (VecDistanceSquared(entities[i].GetWorldPosition(), player_position) < 20 * 20 * ((int)((CNewNPC)entities[i]).IsFlying() + 1)) {
      return false;
    }
  }

  return true;
}

/**
  * this function finds any creature from the supplied list that is inside the
  * radius at the given position, and if it is, teleports it OUTSIDE the radius
  */
function SUH_keepCreaturesOutsidePoint(position: Vector, radius: float, optional entities: array<CEntity>) {
  var distance_from_point: float;
  var old_position: Vector;
  var new_position: Vector;
  var i: int;

  if (entities.Size() == 0) {
    entities = getEntitiesInRange(position, radius);
  }

  for (i = 0; i < entities.Size(); i += 1) {
    old_position = entities[i].GetWorldPosition();

    distance_from_point = VecDistanceSquared(
      old_position,
      position
    );

    if (distance_from_point <= radius) {
      new_position = VecInterpolate(
        position,
        old_position,
        1
      );

      SUH_groundPosition(new_position);

      if (new_position.Z < old_position.Z) {
        new_position.Z = old_position.Z;
      }

      entities[i].Teleport(new_position);
    }
  }
}

/**
 * this function finds any creature from the supplied list that is outside the
 * radius at the given position, and if it is, teleports it back in the radius
 */
function SUH_keepCreaturesOnPoint(position: Vector, radius: float, entities: array<CEntity>) {
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

      SUH_groundPosition(new_position);

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
function SUH_areAllEntitiesDead(entities: array<CEntity>): bool {
  var i: int;

  for (i = 0; i < entities.Size(); i += 1) {
    if (((CActor)entities[i]).GetHealthPercents() >= 0.01) {
      return false;
    }
  }

  return true;
}

latent function SUH_resetEntitiesAttitudes(entities: array<CEntity>) {
  var i: int;

  for (i = 0; i < entities.Size(); i += 1) {
    ((CActor)entities[i])
      .ResetTemporaryAttitudeGroup(AGP_Default);
  }
}

latent function SUH_waitUntilPlayerFinishesCombat(entities: array<CEntity>) {
  // sleep a bit before entering the loop, to avoid a really fast loop if the
  // player runs away from the monster
  Sleep(3);

  while (!SUH_areAllEntitiesDead(entities) && !SUH_areAllEntitiesFarFromPlayer(entities)) {
    SUH_makeEntitiesTargetPlayer(entities);
    SUH_removeDeadEntities(entities);

    Sleep(1);
  }
}