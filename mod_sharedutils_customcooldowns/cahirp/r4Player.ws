@context(
  define(mod.sharedutils.customcooldowns)
  file("game/player/r4Player.ws")
  at(class CR4Player)
)

@insert(
  above(function GetLevel)
)
// sharedutils - custom cooldowns - BEGIN
public saved var custom_cooldowns: array<SU_Cooldown>;
// sharedutils - custom cooldowns - END