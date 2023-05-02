# Sharedutils Oneliners
Adds the ability to render text various size and colour at screen or world coordinates. Also supports images

## Using it
```js
exec function suol_example() {
  // creates a floating text in the world
  SU_oneliner(
    // demonstrates how to change colour & size
    (new SUOL_TagBuilder in thePlayer)
      .tag("font")
      .attr("size", "32")
      .attr("color", "#ff6655")
      .text("Static OL"),
    thePlayer.GetWorldPosition() + Vector(0,0,1)
  ).setRenderDistance(5);

  // add a static piece of text in the middle of the screen
  SU_onelinerScreen(
    "Screen OL",
    Vector(0.5, 0.5)
  );

  // add a floating text that follows an entity
  SU_onelinerEntity(
    "Entity OL",
    thePlayer.GetHorseWithInventory()
  );
}
```