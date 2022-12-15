
function SU_tinyBootstrappedInit(player: CPlayer) {
  player.tiny_bootstrapper = (new SU_TinyBootstrapperManager in player)
    .init();
}

function SUTB_getEntityByTag(tag: name): CEntity {
  return thePlayer.tiny_bootstrapper.getEntityByTag(tag);
}
