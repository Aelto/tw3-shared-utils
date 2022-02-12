
function SU_tinyBootstrappedInit() {
  var player: CPlayer;

  player = (CPlayer)GetWitcherPlayer();

  player.tiny_bootstrapper = (new SU_TinyBootstrapperManager in player)
    .init();
}