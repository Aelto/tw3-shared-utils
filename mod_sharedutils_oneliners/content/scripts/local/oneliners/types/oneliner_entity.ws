
/// A oneliner that follows the world coordinates of an entity
class SU_OnelinerEntity extends SU_Oneliner {
  var entity: CEntity;

  default offset = Vector(0,0,2);
  
  function getPosition(): Vector {
    return this.entity.GetWorldPosition() + this.offset;
  }
}
