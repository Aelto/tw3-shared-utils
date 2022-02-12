/**
 * This file contains an example of how to add a global interaction event
 * listener to the game through the SU_NpcInteraction_GlobalEventHandler class.
 */

/**
 * To create a global interaction event listener you must add a state to the 
 * SU_NpcInteraction_GlobalEventHandler statemachine and extend
 * GlobalEventListener.
 *
 * In this example we are adding MyGlobalEventListener to the statemachine.
 *
 * Note that if two event listeners have the same name the game won't compile,
 * this is intended to ensure good compatibility between mods. For this reason
 * you must use unique names.
 */ 
state MyGlobalEventListener in SU_NpcInteraction_GlobalEventHandler extends GlobalEventListener {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    this.MyGlobalEventListener_main();
  }

  /**
   * states can have undefined behaviors when two states have methods with the
   * same name. For this reason it is recommend to use a prefix on your function
   * names, using the state name is a good solution.
   */
  entry function MyGlobalEventListener_main() {
    var actionName: string;
    var activator: CEntity;
    var receptor: CPeristentEntity;

    // now here you can do anything you want, here we print all the information
    // we have about the interaction.
    theGame
      .GetGuiManager()
      .ShowNotification(
        "received interaction: " + parent.actionName +
        ", activator: " + parent.activator.ToString() +
        ", receptor: " + parent.receptor.ToString()
      );

    // when our job is done, we MUST call the finish method. Not doing so will
    // block the global event listener and it won't work for the rest of the
    // session until the player gets a loading screen.
    this.finish();
  }
}