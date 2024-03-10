@context(
  define("mod.sharedutils.storage")
  file("game/player/playerInput.ws")
  at(class CPlayerInput)
)

@insert(
  note("add a hook on the input initialize function")
  above(var actionLocks)
)
public saved var SU_storage: SU_Storage; // SU - Storage
public var SU_buffer: SU_Storage; // SU - Storage
