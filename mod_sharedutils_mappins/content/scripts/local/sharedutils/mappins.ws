
class SU_MapPin {
  /**
   * This isn't used by the code but only for you to easily identify your pins.
   */
   var tag: String;

  /**
   * when set to true the map pin will appear under the 'Quests' label
   * on the world map filter pane.
   */
   var is_quest: bool;
   default is_quest = false;
   
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
   * A full list of available pins can be found at the bottom of this script.
   */
  var type: String;
  default type = "MonsterQuest";

  /**
   * The filtered type of the pin, this is the filter that the map pin will 
   * fall under, it is best to try use something nothing else is like "QuestReturn".
   * Using a common type will group your pins together with them.
   */
  var filtered_type: String;
  default filtered_type = "QuestReturn";
  
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

  /**
   * Controls whether or not this mappin should appear on the player's minimap.
   */
  var appears_on_minimap: bool;

  function init(
    _tag: String,
    _position: Vector,
    _description: String,
    _label: String,
    _type: String,
  _filtered_type: string,
    _radius: float,
    _region: String,
    _appears_on_minimap: bool,
  _is_quest: bool
  ): SU_MapPin {
    this.tag = _tag;
    this.position = _position;
    this.description = _description;
    this.label = _label;
    this.type = _type;
    this.filtered_type = _filtered_type;
    this.radius = _radius;
    this.region = _region;
    this.appears_on_minimap = _appears_on_minimap;
    this.is_quest = _is_quest;

    return this;
  }
}

function SU_updateCustomMapPins(out flash_array: CScriptedFlashArray, value_storage: CScriptedFlashValueStorage, shown_area: EAreaName) {
  var flash_object: CScriptedFlashObject;
  var custom_pins: array<SU_MapPin>;
  var current_pin: SU_MapPin;
  var region, shown_region: String;
  var i: int;

  custom_pins = thePlayer.customMapPins;

  region = SUH_getCurrentRegion();
  shown_region = AreaTypeToName(shown_area);

  for (i = 0; i < custom_pins.Size(); i += 1) {
    current_pin = custom_pins[i];
  
    // the player is not in the right region or right map view, we skip the pin.
  
  if (current_pin.region != region && current_pin.region != shown_region) {
    continue;
  }

  flash_object = value_storage.CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");
  flash_object.SetMemberFlashString("type", current_pin.type);
  flash_object.SetMemberFlashString("filteredType", current_pin.filtered_type);
  flash_object.SetMemberFlashString("label", current_pin.label);
  flash_object.SetMemberFlashString("description", current_pin.description);
  flash_object.SetMemberFlashNumber("posX", current_pin.position.X);
  flash_object.SetMemberFlashNumber("posY", current_pin.position.Y);
  flash_object.SetMemberFlashNumber("radius", RoundF(current_pin.radius));
  flash_object.SetMemberFlashBool("is_quest", current_pin.is_quest);
    
  //Constants - Should not be modified from these values for our purposes.
  flash_object.SetMemberFlashUInt("id", NameToFlashUInt('User'));
  flash_object.SetMemberFlashNumber("rotation", 0);
  flash_object.SetMemberFlashBool("isPlayer", false);
  flash_object.SetMemberFlashBool("isUserPin", false);
  flash_object.SetMemberFlashBool("highlighted", false);
  flash_object.SetMemberFlashBool("tracked", false);
  flash_object.SetMemberFlashBool("hidden", false);
    flash_array.PushBackFlashObject(flash_object);
  }
}

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

function SU_removeCustomPinByPredicate(predicate_runner: SU_PredicateInterfaceRemovePin) {
  var i: int;
  var current_pin: SU_MapPin;
  var last_pin: SU_MapPin;
  
  for (i = 0; i < thePlayer.customMapPins.Size(); i += 1) {
    current_pin = thePlayer.customMapPins[i];

    if (!predicate_runner.predicate(current_pin)) {
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

/**
 * This is an abstract class that acts as an interface for any function that
 * requires some sort of predicate. Because the language doesn't support lambdas
 * nor function pointers, this is the only viable solution.
 *
 * To use it, extend the class and override the right methods according to your
 * needs.
 */
abstract class SU_PredicateInterfaceRemovePin {
  /**
   * Override the method and return true to perform the action that is described
   * by the function asking for a PredicateInterface
   */
  function predicate(pin: SU_MapPin): bool {
    return false;
  }
}

/**
 * This is a predicate interface i felt could be useful so it comes prebuilt in
 * the utility
 */
class SU_CustomPinRemoverPredicateTagIncludesSubstring extends SU_PredicateInterfaceRemovePin {
  var substring: String;

  function predicate(pin: SU_MapPin): bool {
    return StrContains(pin.tag, this.substring);
  }
}

function SU_updateMinimapPins() {
  var minimapModule : CR4HudModuleMinimap2;
  var m_AddMapPin : CScriptedFlashFunction;
  var m_MovePin : CScriptedFlashFunction;
  var flashModule : CScriptedFlashSprite;
  var hud : CR4ScriptedHud;
  var pin: SU_MapPin;
  var i: int;

  hud = (CR4ScriptedHud)theGame.GetHud();
  if (hud) {
    minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");

    if (minimapModule) {
      flashModule = minimapModule.GetModuleFlash();
      m_AddMapPin = flashModule.GetMemberFlashFunction( "AddMapPin" );
      m_MovePin = flashModule.GetMemberFlashFunction( "MoveMapPin" );

      for (i = 0; i < thePlayer.customMapPins.Size(); i += 1) {
        pin = thePlayer.customMapPins[i];

        if (!pin.appears_on_minimap) {
          continue;
        }

        m_AddMapPin.InvokeSelfNineArgs(
          FlashArgInt(i),
          FlashArgString("Enemy"), // tag
          FlashArgString("Enemy"), 
          FlashArgNumber(pin.radius), // radius
          FlashArgBool(true), // can be pointed by arrows
          FlashArgInt(0), // priority
          FlashArgBool(true), // is quest pin
          FlashArgBool(false), // is user pin
          FlashArgBool(true), // highlighted
        );

        m_MovePin.InvokeSelfFourArgs(
          FlashArgInt(i),
          FlashArgNumber(pin.position.X),
          FlashArgNumber(pin.position.Y),
          FlashArgNumber(pin.radius)
        );
      }
    }
  }
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

/*
"RoadSign"
"Harbor"
"NoticeBoardFull"
"NoticeBoard"
"PlayerStash"
"PlayerStashDiscoverable"
"Horse"
"StoryQuest"
"ChapterQuest"
"SideQuest"
"MonsterQuest"
"TreasureQuest"
"QuestReturn"
"HorseRace"
"NonQuestHorseRace"
"BoatRace"
"QuestBelgard"
"QuestCoronata"
"QuestVermentino"
"QuestAvailable"
"QuestAvailableHoS"
"QuestAvailableBaW"
"Entrance"
"NotDiscoveredPOI"
"NotDiscoveredPOI_1"
"NotDiscoveredPOI_2"
"NotDiscoveredPOI_3"
"MonsterNest"
"MonsterNest_1"
"MonsterNest_2"
"MonsterNest_3"
"MonsterNestDisabled"
"TreasureHuntMappin"
"TreasureHuntMappin_1"
"TreasureHuntMappin_2"
"TreasureHuntMappin_3"
"TreasureHuntMappinDisabled"
"SpoilsOfWar"
"SpoilsOfWar_1"
"SpoilsOfWar_2"
"SpoilsOfWar_3"
"SpoilsOfWarDisabled"
"BanditCamp"
"BanditCamp_1"
"BanditCamp_2"
"BanditCamp_3"
"BanditCampDisabled"
"BanditCampfire"
"BanditCampfire_1"
"BanditCampfire_2"
"BanditCampfire_3"
"BanditCampfireDisabled"
"BossAndTreasure"
"BossAndTreasure_1"
"BossAndTreasure_2"
"BossAndTreasure_3"
"BossAndTreasureDisabled"
"Contraband"
"Contraband_1"
"Contraband_2"
"Contraband_3"
"ContrabandDisabled"
"ContrabandShip"
"ContrabandShip_1"
"ContrabandShip_2"
"ContrabandShip_3"
"ContrabandShipDisabled"
"RescuingTown"
"RescuingTown_1"
"RescuingTown_2"
"RescuingTown_3"
"RescuingTownDisabled"
"DungeonCrawl"
"DungeonCrawl_1"
"DungeonCrawl_2"
"DungeonCrawl_3"
"DungeonCrawlDisabled"
"Hideout"
"HideoutDisabled"
"InfestedVineyard"
"InfestedVineyard_1"
"InfestedVineyard_2"
"InfestedVineyard_3"
"InfestedVineyardDisabled"
"Plegmund"
"WineContract"
"KnightErrant"
"SignalingStake"
"Boat"
"Shopkeeper"
"Archmaster"
"Blacksmith"
"Armorer"
"Hairdresser"
"Alchemic"
"Herbalist"
"Innkeeper"
"Enchanter"
"Prostitute"
"Hairdresser"
"Torch"
"WineMerchant"
"DyeMerchant"
"Cammerlengo"
"PlaceOfPower"
"PlaceOfPower_1"
"PlaceOfPower_2"
"PlaceOfPower_3"
"PlaceOfPowerDisabled"
"Whetstone"
"GrindStone"
"ArmorRepairTable"
"AlchemyTable"
"MutagenDismantle"
"Bookshelf"
*/