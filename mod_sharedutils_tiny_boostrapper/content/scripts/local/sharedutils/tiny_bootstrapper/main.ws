
function SU_tinyBootstrappedInit(player: CPlayer) {
  player.tiny_bootstrapper = (new SU_TinyBootstrapperManager in player)
    .init();
}