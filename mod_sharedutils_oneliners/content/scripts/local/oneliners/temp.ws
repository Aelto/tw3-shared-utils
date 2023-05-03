exec function suol_example() {
  SU_oneliner(
    (new SUOL_TagBuilder in thePlayer)
      .tag("font")
      .attr("size", "32")
      .attr("color", "#ff6655")
      .text("Static OL"),
    thePlayer.GetWorldPosition() + Vector(0,0,1)
  ).setRenderDistance(5);

  SU_onelinerScreen(
    "Screen OL",
    Vector(0.5, 0.5)
  );

  SU_onelinerEntity(
    "Entity OL",
    thePlayer.GetHorseWithInventory()
  );
}

exec function suol_status() {
  SU_onelinerStatus("Breaking news: Village slain by forest creature!");
}

exec function suol_statuss() {
  SU_onelinerStatus("Today's question: Are witchers supposed to stay neutral at all cost?");
}