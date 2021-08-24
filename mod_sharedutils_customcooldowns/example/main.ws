
/**
 * simple example using a premade class from sharedutils
 */
exec function test1() {
  var cooldown: SU_CooldownCounter;

  cooldown = new SU_CooldownCounter in thePlayer;
  SU_addCustomCooldown(cooldown);
}

/**
 * example using a custom class that extends the premade classes from sharedutils
 */
exec function test2() {
  var cooldown: TestTimer;

  cooldown = new TestTimer in thePlayer;
  cooldown.counter_limit = 5;

  SU_addCustomCooldown(cooldown);
}

class TestTimer extends SU_CooldownTimer {
  function onComplete(): bool {
    theGame
    .GetGuiManager()
    .ShowNotification("completed");

    return true;
  }
}