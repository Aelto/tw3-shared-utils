@context(
  define(mod.sharedutils.customcooldowns)
  file("game/gui/hud/modules/hudModuleBuffs.ws")
  at(class CR4HudModuleBuffs)
)

@insert(
  at(event OnTick)
  above(if ( _currentEffects.Size() == 0 && _previousEffects.Size() == 0)
)
// sharedutils - custom cooldowns - BEGIN
SU_updateCustomCooldownsDuration(i - offset, timeDelta, m_fxSetPercentSFF, this);
// sharedutils - custom cooldowns - END


@insert(
  at(event OnTick)
  select(if ( _currentEffects.Size() == 0 && _previousEffects.Size() == 0 ))
)
if ( _currentEffects.Size() == 0 && _previousEffects.Size() == 0 && thePlayer.custom_cooldowns.Size() == 0 ) // sharedutils - custom cooldowns - BEGIN & END