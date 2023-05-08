
/// A oneliner that follows the world coordinates of an entity
class SU_OnelinerEntity extends SU_Oneliner {
  var entity: CEntity;

  function getPosition(): Vector {
    return this.entity.GetWorldPosition() + this.offset;
  }
}
