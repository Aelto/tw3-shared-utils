function SU_injectCustomCooldowns(out flash_array: CScriptedFlashArray, value_storage: CScriptedFlashValueStorage, module: CR4HudModuleBuffs) {
  var l_flashObject: CScriptedFlashObject;
  var current_cooldown: SU_Cooldown;
  var i: int;

  for (i = 0; i < thePlayer.custom_cooldowns.Size(); i += 1) {
    current_cooldown = thePlayer.custom_cooldowns[i];

    l_flashObject = value_storage.CreateTempFlashObject();
    l_flashObject.SetMemberFlashBool("isVisible", current_cooldown.is_visible);
    l_flashObject.SetMemberFlashString("iconName", current_cooldown.icon_name);
    l_flashObject.SetMemberFlashString("title", current_cooldown.title);
    l_flashObject.SetMemberFlashBool("IsPotion", current_cooldown.is_potion);
    l_flashObject.SetMemberFlashInt("isPositive", current_cooldown.buff_state);
    l_flashObject.SetMemberFlashInt("format", current_cooldown.format);
    l_flashObject.SetMemberFlashNumber("duration", current_cooldown.counter);

    if (current_cooldown.counter_limit > -1) {
      l_flashObject.SetMemberFlashNumber("initialDuration", current_cooldown.counter_limit);
    }
    else {
      l_flashObject.SetMemberFlashNumber("initialDuration", current_cooldown.counter);
    }

    flash_array.PushBackFlashObject(l_flashObject);
  }
}

function SU_updateCustomCooldownsDuration(offset: int, delta: float, m_fxSetPercentSFF : CScriptedFlashFunction, module: CR4HudModuleBuffs) {
  var should_refresh_interface: bool;
  var current_cooldown: SU_Cooldown;
  var seconds: float;
  var time: float;
  var i: int;

  seconds = theGame.GetEngineTimeAsSeconds();

  should_refresh_interface = false;
  for (i = 0; i < thePlayer.custom_cooldowns.Size(); i += 1) {
    thePlayer.custom_cooldowns[i].tick(delta, seconds);

    current_cooldown = thePlayer.custom_cooldowns[i];

    if (!current_cooldown) {
      thePlayer.custom_cooldowns.EraseFast(i);
      should_refresh_interface = true;
      i -= 1;

      continue;
    }

    m_fxSetPercentSFF.InvokeSelfFourArgs(
      FlashArgNumber(i + offset),
      FlashArgNumber(current_cooldown.counter),
      FlashArgNumber(current_cooldown.counter_limit),
      FlashArgInt(10)
    );

    if (current_cooldown.shouldEnd() && current_cooldown.onComplete()) {
      SU_removeCustomCooldown(current_cooldown);
    }
  }

  if (should_refresh_interface) {
    SU_refreshCustomCooldownInterface(SU_getBuffsModule());
  }
}