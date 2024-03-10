@context(
  define("mod.sharedutils.tiny_bootstrapper")
  file("game/player/playerInput.ws")
  at(class CPlayerInput)
)

@insert(
  note("add a hook on the input initialize function")
  at(function Initialize)
  at(theInput.RegisterListener)
  above(if(previousInput))
)
SU_tinyBootstrapperInit(this);  // SU - tiny_bootstrapper

@insert(
  function Destroy
  below({)
)
SU_tinyBootstrapperStop(this); // SU - tiny_bootstrapper