
abstract class SU_Cooldown {
   /**
   * internal value, do not set this value
   */
  var injection_time: float;

  /**
   * the displayed value. Calculated automatically if the state is 3 or 4
   */
  var counter: float;
  default counter = 0;

  /**
   * if the state is 3 or 4 (counter):
   * controls for how long the buff should be displayed, in seconds.
   *
   * if the state is differant than 3 or 4:
   * if the `this.counter` is greater or equal than the limit the buff is
   * removed automatically.
   *
   * if set to -1, then it means the buff is infinite.
   */
  var counter_limit: float;
  default counter_limit = -1;

  var is_visible: bool;
  default is_visible = true;

  var icon_name: string;

  var title: string;

  var is_potion: bool;
  default is_potion = false;

  /**
   * 0 = negative
   * 1 = positive
   * 2 = neutral
   */
  var buff_state: int;
  default buff_state = 1;

  /**
   * 0 = nothing
   * 1 = counter
   * 2 = counter with percent
   * 3 = timer
   * 4 = timer (circle) + percents (text)
   **/
  var format: int;
  default format = 3;

  /**
   * made to be overridden.
   * the return value tell if the cooldown should be removed or not. A return
   * value of `true` means it should be removed, a return value of `false` means
   * the cooldown icon will stay. It can be useful for repeating cooldowns.
   */
  function onComplete(): bool {
    return true;
  }

  /**
   * made to be overridden
   * this function is called every UI tick. Its role is to update the counter
   * value based on any value you want.
   */
  function tick(delta: float, engine_time_as_seconds: float) {

  }

  /**
   * made to be overridden
   * - a return value of `true` means the cooldown should end and the `onComplete`
   * event will be called.
   * - a return value of `false` means the cooldown should continue and the
   *  `tick` function will continue to be called.
   */
  function shouldEnd(): bool {
    return true;
  }
}

/**
 * a basic timer class, the value starts at the counter limit and goes down
 * until it reaches 0.
 *
 * you can override the class and setup a onComplete method
 * if custom code needs to run when the cooldown is over.
 */
class SU_CooldownTimer extends SU_Cooldown {
  /**
   * set a custom value for the timer. By default it is 30 seconds
   */
  default counter_limit = 30;

  /**
   * do not change this value.
   */
  default format = 3;

  function shouldEnd(): bool {
    return this.counter_limit <= 0
        || this.counter <= 0;
  }

  function tick(delta: float, engine_time_as_seconds: float) {
    var time: float;

    // variable because the compiler doesn't know how to do multiple
    // substractions for some reason.
    time = engine_time_as_seconds - this.injection_time;
    this.counter = this.counter_limit - time;
  }
}

/**
 * a basic counter class, the value starts at 0 and goes up until the counter
 * limit.
 *
 * you can override the class and setup a onComplete 
 * method if custom code needs to run when the cooldown is over.
 */
class SU_CooldownCounter extends SU_Cooldown {
  /**
   * set a custom value for the counter. By default it is 30
   */
  default counter_limit = 30;

  /**
   * do not change this value.
   */
  default format = 1;

  function shouldEnd(): bool {
    return this.counter_limit < 0
        || this.counter >= this.counter_limit;
  }

  function tick(delta: float, engine_time_as_seconds: float) {
    var time: float;

    // variable because the compiler doesn't know how to do multiple
    // substractions for some reason.
    time = engine_time_as_seconds - this.injection_time;
    this.counter = time;
  }
}