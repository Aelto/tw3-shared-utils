
/**
 * To create a bootstrapped mod you must add a state to the 
 * SU_TinyBootstrapperManager statemachine and extend BaseMod.
 *
 * In this example we are adding MyBoostrappedMod to the statemachine.
 *
 * Note that if two bootstrap mods have the same name the game won't compile,
 * this is intended to ensure good compatibility between mods. For this reason
 * you must use unique names.
 */ 
state MyBoostrappedMod in SU_TinyBootstrapperManager extends BaseMod {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    this.MyBoostrappedMod_main();
    this.finish();
  }

  /**
   * states can have undefined behaviors when two states have methods with the
   * same name. For this reason it is recommend to use a prefix on your function
   * names, using the state name is a good solution.
   */
  entry function MyBoostrappedMod_main() {
    LogChannel('MyBoostrappedMod', "MyBoostrappedMod was bootstrapped!");
  }
}