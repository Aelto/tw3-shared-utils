exec function SU_addExampleHoverListener()  {
  SU_addDialogHoverListener(new SU_ExampleHoverListener in thePlayer);
}

class SU_ExampleHoverListener extends SU_DialogHoverListener {
  function onHover(scene_choice: SSceneChoice, index: int) {
    theGame
    .GetGuiManager()
    .ShowNotification(
      "description = " + scene_choice.description + " index = " + index
    );
  }
}