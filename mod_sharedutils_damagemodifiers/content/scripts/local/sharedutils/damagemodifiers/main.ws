
function SU_damageModifier(out action: W3DamageAction) {
  var damage_modifier: SU_BaseDamageModifier;
  var attacker: CNewNPC;
  var victim: CNewNPC;
  var i: int;
  
  attacker = (CNewNPC)action.attacker;
  if (attacker) {
    for (i = 0; i < attacker.sharedutils_damage_modifiers.Size(); i += 1) {
      damage_modifier = attacker.sharedutils_damage_modifiers[i];

      damage_modifier.modifyActionAsAttacker(action);
    }
  }

  victim = (CNewNPC)action.victim;
  if (victim) {
    for (i = 0; i < victim.sharedutils_damage_modifiers.Size(); i += 1) {
      damage_modifier = victim.sharedutils_damage_modifiers[i];

      damage_modifier.modifyActionAsVictim(action);
    }
  }
}
