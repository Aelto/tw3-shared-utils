@context(
  define(mod.sharedutils.damage_modifiers)
  file("game/gameplay/damage/damageManagerProcessor.ws")
  at(class W3DamageManagerProcessor)
)

@insert(
  at(function ProcessActionDamage)
  above(if(size == 0 && canLog))
)
SU_damageModifier(action, this.playerAttacker, this.attackAction); // sharedutils_damagemodifiers