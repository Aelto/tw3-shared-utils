@addField(CNewNPC)
var sharedutils_damage_modifiers: array<SU_BaseDamageModifier>;

@wrapMethod(CActor)
function ReduceDamage(out damageData: W3DamageAction) {
  wrappedMethod(damageData);
  SU_damageModifier(damageData);
}