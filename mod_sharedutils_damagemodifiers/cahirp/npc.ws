@context(
  define(mod.sharedutils.damage_modifiers)
  file("game/npc/npc.ws")
  at(class CNewNPC)
)

@insert(
  above(var tauntedToAttackTimeStamp)
)
// modSharedutils_damagemodifiers - BEGIN
public var sharedutils_damage_modifiers: array<SU_BaseDamageModifier>;
// modSharedutils_damagemodifiers - END