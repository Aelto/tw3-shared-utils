
function SU_fhudPatchAddCustomMarkers(fhud: CModMarkers): array<SMod3DMarker> {
  var current_mappin: SU_MapPin;
  var new_marker: SMod3DMarker;
  var player_position: Vector;
  var first_coords: Vector;
  var cache: array<SMod3DMarker>;
  var i: int;

  player_position = thePlayer.GetWorldPosition();


  for (i = 0; i < thePlayer.customMapPins.Size(); i += 1) {
    current_mappin = thePlayer.customMapPins[i];
    new_marker = SMod3DMarker();

    new_marker.visibleType = SU_mapPinTypeToName(current_mappin.type);
    new_marker.isDiscovered = true;
    new_marker.isKnown = true;
    new_marker.isDisabled = false;

    new_marker.position = current_mappin.position;
    new_marker.position.Z = player_position.Z;

    new_marker.isHighlighted = true;
    new_marker.isActiveQuest = false;
    
    // skipping the config on both of them too
    new_marker.force = false || fhud.ShouldForceMarker(new_marker);
    new_marker.pin = true || fhud.ShouldPinMarker(new_marker);

    // skipping the config on purpose
    // if (!fhud.ShouldShowMarker(new_marker)) {
    //   continue;
    // }

    new_marker.description = current_mappin.label;
    new_marker.text = fhud.GetMarkerIconByType(new_marker);

    cache.PushBack(new_marker);
  }

  return cache;
}

function SU_mapPinTypeToName(type: String): name {
  switch (type) {
    case "QuestReturn":
      return 'QuestReturn';
    case "MonsterQuest":
      return 'MonsterQuest';
    case "QuestGiverStory":
      return 'QuestGiverStory';
    case "QuestGiverChapter":
      return 'QuestGiverChapter';
    case "QuestGiverSide":
      return 'QuestGiverSide';
    case "TreasureQuest":
      return 'TreasureQuest';
    default:
      return 'MonsterQuest';
  }
}