/**
  * list of possible regions:
  *  - no_mans_land
  *  - skellige
  *  - bob
  *  - prolog_village
  *  - kaer_morhen
  */
function SUH_getCurrentRegion(): string {
  var region: string;

  region = AreaTypeToName(theGame.GetCommonMapManager().GetCurrentArea());

  return SUH_normalizeRegion(region);
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
  if (region == "novigrad") {
    return "no_mans_land";
  }

  if (region == "prolog_village_winter") {
    return "prolog_village";
  }

  return region;
}
