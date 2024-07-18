
function SU_removeCustomPin(pin: SU_MapPin, optional manager: SUMP_Manager): bool {
  var i: int;

  if (!manager) {
    manager = SUMP_getManager();
  }

  if (!manager) {
    SUMP_Logger("SU_removeCustomPin(), manager not found");

    return false;
  }

  i = manager.mappins.FindFirst(pin);
  if (i < 0) {
    return false;
  }

  manager.mappins.EraseFast(i);
  return true;
}

function SU_removeCustomPinByTagPrefix(prefix: string) {
  SU_removeCustomPinByPredicate(
    (new SU_CustomPinRemoverPredicateTagStartsWith in thePlayer)
      .init(prefix)
  );
}

function SU_removeCustomPinByTag(tag: String) {
  SU_removeCustomPinByPredicate(
    (new SU_CustomPinRemoverPredicateTagEquals in thePlayer)
      .init(tag)
  );
}

function SU_removeCustomPinByPosition(position: Vector) {
  SU_removeCustomPinByPredicate(
    (new SU_CustomPinRemoverPredicatePositionEquals in thePlayer)
      .init(position)
  );
}

function SUMP_getManager(): SUMP_Manager {
  SUMP_Logger("SUMP_getManager()");
	
	return thePlayer.getSharedutilsMappinsManager();
}

////////////////////////////////////////////////////////////////////////////////
//       A series of prebuilt predicate removers that may be useful           //
////////////////////////////////////////////////////////////////////////////////

class SU_CustomPinRemoverPredicateTagIncludesSubstring extends SU_PredicateInterfaceRemovePin {
  var substring: String;

  function predicate(pin: SU_MapPin): bool {
    return StrContains(pin.tag, this.substring);
  }
}

class SU_CustomPinRemoverPredicateTagStartsWith extends SU_PredicateInterfaceRemovePin {
  var prefix: String;

  function predicate(pin: SU_MapPin): bool {
    return StrContains(pin.tag, this.prefix);
  }

  function init(prefix: String): SU_CustomPinRemoverPredicateTagStartsWith {
    this.prefix = prefix;

    return this;
  }
}

class SU_CustomPinRemoverPredicateTagEquals extends SU_PredicateInterfaceRemovePin {
  var tag: String;

  function predicate(pin: SU_MapPin): bool {
    return pin.tag == this.tag;
  }

  function init(tag: String): SU_CustomPinRemoverPredicateTagEquals {
    this.tag = tag;

    return this;
  }
}

class SU_CustomPinRemoverPredicatePositionEquals extends SU_PredicateInterfaceRemovePin {
  var position: Vector;

  function predicate(pin: SU_MapPin): bool {
	return pin.position == this.position;
  }

  function init(position: Vector): SU_CustomPinRemoverPredicatePositionEquals {
    this.position = position;

    return this;
  }
}

////////////////////////////////////////////////////////////////////////////////
//                          Utility functions                                 //
////////////////////////////////////////////////////////////////////////////////

function SUMP_getGroundPosition(out input_position: Vector, optional personal_space: float, optional radius: float): bool {
  var found_viable_position: bool;
  var collision_normal: Vector;
  var max_height_check: float;
  var output_position: Vector;
  var point_z: float;
  var attempts: int;

  attempts = 10;
  output_position = input_position;
  personal_space = MaxF(personal_space, 1.0);
  max_height_check = 30.0;

  if (radius == 0) {
    radius = 10.0;
  }

  do {
    attempts -= 1;

    // first search for ground based on navigation data.
    theGame
    .GetWorld()
    .NavigationComputeZ(
      output_position,
      output_position.Z - max_height_check,
      output_position.Z + max_height_check,
      point_z
    );

    output_position.Z = point_z;

    if (!theGame.GetWorld().NavigationFindSafeSpot(output_position, personal_space, radius, output_position)) {
      continue;
    }

    // then do a static trace to find the position on ground
    // ... okay i'm not sure anymore, is the static trace needed?
    // theGame
    // .GetWorld()
    // .StaticTrace(
    //   output_position + Vector(0,0,1.5),// + 5,// Vector(0,0,5),
    //   output_position - Vector(0,0,1.5),// - 5,//Vector(0,0,5),
    //   output_position,
    //   collision_normal
    // );

    // finally, return if the position is above water level
    if (output_position.Z < theGame.GetWorld().GetWaterLevel(output_position, true)) {
      continue;
    }

    found_viable_position = true;
    break;
  } while (attempts > 0);


  if (found_viable_position) {
    input_position = output_position;

    return true;
  }

  return false;
}
