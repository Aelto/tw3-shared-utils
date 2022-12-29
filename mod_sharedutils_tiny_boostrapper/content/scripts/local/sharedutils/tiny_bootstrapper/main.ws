
function SU_tinyBootstrapperInit(player_input: CPlayerInput) {
  if (!player_input.SU_tiny_bootstrapper_manager) {
    player_input.SU_tiny_bootstrapper_manager = new SU_TinyBootstrapperManager in player_input;
  }

  player_input.SU_tiny_bootstrapper_manager.init();
}

function SU_tinyBootstrapperStop(player_input: CPlayerInput) {
  player_input.SU_tiny_bootstrapper_manager.stopMods();
}

function SUTB_getModByTag(tag: name): SU_BaseBootstrappedMod {
  return thePlayer.GetInputHandler()
    .SU_tiny_bootstrapper_manager
    .getModByTag(tag);
}
