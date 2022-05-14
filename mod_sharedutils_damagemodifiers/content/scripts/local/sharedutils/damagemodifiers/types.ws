
/**
 * Extend the class to add any kind of modifier you may need
 */
class SU_BaseDamageModifier {
  /**
   * A float in the [0;+inf] range where:
   * 0 means 0% of the intended damage,
   * 1 means 100% of the intended damage
   * 2 means 200 of the intended damage
   */
  public var damage_dealt_modifier: float;
  default damage_dealt_modifier = 1.0;

  /**
   * A float in the [0;+inf] range where:
   * 0 means 0% of the intended damage,
   * 1 means 100% of the intended damage
   * 2 means 200 of the intended damage
   */
  public var damage_received_modifier: float;
  default damage_received_modifier = 1.0;

  public function modifyActionAsVictim(out action: W3DamageAction) {
    action.processedDmg.vitalityDamage *= this.damage_received_modifier;
    action.processedDmg.essenceDamage *= this.damage_received_modifier;
  }

  public function modifyActionAsAttacker(out action: W3DamageAction) {
    action.processedDmg.vitalityDamage *= this.damage_dealt_modifier;
    action.processedDmg.essenceDamage *= this.damage_dealt_modifier;
  }
}