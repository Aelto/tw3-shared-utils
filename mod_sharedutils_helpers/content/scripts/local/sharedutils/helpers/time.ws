/**
 * Return the current timestamp
 */
function SUH_now(): float {
  return theGame.GetEngineTimeAsSeconds();
}

/**
 * Return the elapsed duration since the supplied timestamp
 */
function SUH_elapsed(since: float): float {
  return SUH_now() - since;
}

/**
 * Return whether `duration` seconds have passed since the supplied timestamp
 */
function SUH_hasElapsed(since: float, duration: float): bool {
  return SUH_elapsed(since) >= duration;
}