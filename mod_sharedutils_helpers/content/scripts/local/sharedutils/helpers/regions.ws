/**
  * list of possible regions:
  *  - no_mans_land
  *  - skellige
  *  - bob
  *  - prolog_village
  *  - kaer_morhen
  */
function SUH_getCurrentRegion(): string {
  return SUH_normalizeRegion(
    theGame
      .GetCommonMapManager()
      .GetCurrentArea()
  );
}

/**
 * list of available regions:
 *  - no_mans_land
 *  - skellige
 *  - bob
 *  - prolog_village
 *  - kaer_morhen
 */
function SUH_isPlayerInRegion(region: string): bool {
  return SUH_getCurrentRegion() == region;
}

/**
 * Some regions of the game have multiple names, because of multiple variants
 * or because they are split into smaller areas. This function normalizes all of
 * these areas into single areas to make naming & coding simpler.
 */
function SUH_normalizeRegion(region: string): string {
  switch (region) {
    case "novigrad":
    case "AN_Velen":
    case "AN_NMLandNovigrad":
      return "no_mans_land";
      break;

    case "prolog_village_winter":
    case "AN_Prologue_Village_Winter":
    case "AN_Prologue_Village":
      return "prolog_village";
      break;

    case "skellige":
    case "AN_Skellige_ArdSkellig":
      return "skellige";
      break;

    case "bob":
    case "AN_Bob":
      return "bob";
      break;

    case "kaer_morhen":
    case "AN_Kaer_Morhen":
      return "kaer_morhen";
      break;
  }

  return region;
}
