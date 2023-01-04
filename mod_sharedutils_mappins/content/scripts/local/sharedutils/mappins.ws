
function SU_removeCustomPinByTag(tag: String) {
  var i: int;
  var current_pin: SU_MapPin;
  
  for (i = 0; i < thePlayer.customMapPins.Size(); i += 1) {
    current_pin = thePlayer.customMapPins[i];

    if (current_pin.tag != tag) {
      continue;
    }

    if (i == thePlayer.customMapPins.Size() - 1) {
      thePlayer.customMapPins.PopBack();
      SU_removeMinimapPin(i);
      continue;
    }

    thePlayer.customMapPins.Erase(i);
    SU_removeMinimapPin(i);
    i -= 1;
  }
}

function SU_removeCustomPinByPosition(position: Vector) {
  var i: int;
  var current_pin: SU_MapPin;
  var last_pin: SU_MapPin;
  
  for (i = 0; i < thePlayer.customMapPins.Size(); i += 1) {
    current_pin = thePlayer.customMapPins[i];

    if (current_pin.position.X != position.X
    ||  current_pin.position.Y != position.Y) {
      continue;
    }

    if (i == thePlayer.customMapPins.Size() - 1) {
      thePlayer.customMapPins.PopBack();
      SU_removeMinimapPin(i);
      continue;
    }

    thePlayer.customMapPins.Erase(i);
    SU_removeMinimapPin(i);
    i -= 1;
  }
}

function SU_removeCustomPinByIndex(index: int) {
  thePlayer.customMapPins.Erase(index);
  SU_removeMinimapPin(index);
}

function SU_removeMinimapPin(old_index: int) {
  var minimapModule : CR4HudModuleMinimap2;
  var m_DeleteMapPin : CScriptedFlashFunction;
  var flashModule : CScriptedFlashSprite;
  var hud : CR4ScriptedHud;
  var pin: SU_MapPin;
  var i: int;

  hud = (CR4ScriptedHud)theGame.GetHud();
  if (hud) {
    minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");

    if (minimapModule) {
      flashModule = minimapModule.GetModuleFlash();
      m_DeleteMapPin = flashModule.GetMemberFlashFunction( "DeleteMapPin" );

      m_DeleteMapPin.InvokeSelfOneArg(
        FlashArgInt(old_index)
      );
    }
  }
}
