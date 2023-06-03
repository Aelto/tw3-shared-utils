
function SUH_notification(message: string, optional duration: float) {
  theGame
  .GetGuiManager()
  .ShowNotification(message, duration);
}

function SUH_hud(message: string) {
  thePlayer.DisplayHudMessage(message);
}

function SUH_tutorial(title: string, body: string, optional do_not_pause: bool) {
  var tut: W3TutorialPopupData;

  tut = new W3TutorialPopupData in thePlayer;

  tut.managerRef = theGame.GetTutorialSystem();
  tut.messageTitle = title;
  tut.messageText = body;

  tut.enableGlossoryLink = false;
  tut.autosize = true;
  tut.blockInput = !do_not_pause;
  tut.pauseGame = !do_not_pause;
  tut.fullscreen = true;
  tut.canBeShownInMenus = true;

  tut.duration = -1; // input
  tut.posX = 0;
  tut.posY = 0;
  tut.enableAcceptButton = true;
  tut.fullscreen = true;

  if (do_not_pause) {
    tut.blockInput = false;
    tut.pauseGame = false;
    tut.enableAcceptButton = false;
    tut.duration = 10;
  }

  theGame.GetTutorialSystem().ShowTutorialHint(tut);
}

function SUH_toggleHUD() {
  var hud : CR4ScriptedHud;

  hud = (CR4ScriptedHud)theGame.GetHud();

  if (hud) {
    hud.ToggleHudByUser();
  }
}

/// Display a tutorial popup only when the given menu toggle is at `true`. If it
/// is displayed, the given toggle is automatically set to `false`
///
/// 
function SUH_tutorialWhen(menu: name, field: name, string_key: string): bool {
  var sus: SUS_Wrapper = SUS();

  if (sus.bool(menu, name)) {
    SUH_tutorial(
      GetLocStringByKey(string_key+"_title"),
      GetLocStringByKey(string_key+"_body"),
    );

    sus.write(menu, name, false);

    return true;
  }

  return false;
}
