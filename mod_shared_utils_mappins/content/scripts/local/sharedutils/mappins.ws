
class SU_MapPin {
  /**
   * This isn't used by the code but only for you to easily identify your pins.
   */
   var tag: String;

  /**
   * represents the position of the pin, only X and Y values matter as the map
   * is in 2D.
   */
  var position: Vector;

  /**
   * the description that is displayed when the player hovers the cursor over 
   * the pin on the map.
   */
  var description: String;

  /**
   * the name of the pin that is displayed when the player hovers the cursor
   * over the pin on the map.
   */
  var label: String;

  /**
   * The type of the pin, it changes the icon of the pin.
   * Here is a list of all available types:
   * - QuestReturn
   * - MonsterQuest
   * - QuestGiverStory
   * - QuestGiverChapter
   * - QuestGiverSide
   * - TreasureQuest
   */
  var type: String;
  default type = "MonsterQuest";

  /**
   * The radius of the quest on the map, it controls the radius of the yellow,
   * low opacity circle around the marker.
   */
  var radius: float;

  /**
   * Controls in which region it will display the pin, the player has to be in
   * the region for the marker to appear.
   * - prolog_village || prolog_village_winter
   * - no_mans_land || novigrad
   * - skellige
   * - kaer_morhen
   * - bob
   */
  var region: String;
}

function SU_updateCustomMapPins(out flash_array: CScriptedFlashArray, value_storage: CScriptedFlashValueStorage) {
  var flash_object: CScriptedFlashObject;
  var custom_pins: array<SU_MapPin>;
  var current_pin: SU_MapPin;
  var pin_region: String;
  var region: String;
  var i: int;

  custom_pins = thePlayer.customMapPins;

  region = AreaTypeToName(theGame.GetCommonMapManager().GetCurrentArea());

  // this is done to sub regions into the same region. Prolog or ProloWinter are
  // both White Orchard. And noMansLand and Novigrad are both Velen.
  if (region == "prolog_village_winter") {
    region = "prolog_village";
  }
  if (region == "novigrad") {
    region = "no_mans_land";
  }

  for (i = 0; i < custom_pins.Size(); i += 1) {
    current_pin = custom_pins[i];

    pin_region = current_pin.region;

    if (pin_region == "prolog_village_winter") {
      pin_region = "prolog_village";
    }
    if (pin_region == "novigrad") {
      pin_region = "no_mans_land";
    }

    // the player is not in the right region, we skip the pin.
    if (pin_region != region) {
      continue;
    }

    flash_object = value_storage.CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");
    flash_object.SetMemberFlashUInt("id", NameToFlashUInt('User'));
    flash_object.SetMemberFlashNumber("posX", current_pin.position.X);
    flash_object.SetMemberFlashNumber("posY", current_pin.position.Y);
    flash_object.SetMemberFlashString("description", current_pin.description);
    flash_object.SetMemberFlashString("label", current_pin.label);
    flash_object.SetMemberFlashString("type", current_pin.type);
    flash_object.SetMemberFlashNumber("radius", RoundF(current_pin.radius));

    flash_object.SetMemberFlashBool("isQuest", false);
    flash_object.SetMemberFlashBool("isPlayer", false);
    flash_object.SetMemberFlashNumber("rotation", 0);

    flash_array.PushBackFlashObject(flash_object);
  }
}