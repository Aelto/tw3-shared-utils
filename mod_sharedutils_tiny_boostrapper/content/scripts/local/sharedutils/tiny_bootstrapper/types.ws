statemachine class SU_TinyBootstrapperManager {
  protected var states_to_process: array<name>;

  var receptor: CEntity;

  public function init(): SU_TinyBootstrapperManager {
    this.states_to_process = theGame.GetDefinitionsManager()
      .GetItemsWithTag('SU_TinyBootstrapperManager');

    this.GotoState('Waiting');

    return this;
  }
}

/**
 * The state all global event listeners should extend.
 */
state BaseMod in SU_TinyBootstrapperManager {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
  }

  public function finish() {
    parent.GotoState('Waiting');
  }
}

state Empty in SU_TinyBootstrapperManager {}
state Waiting in SU_TinyBootstrapperManager {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);
    this.Waiting_main(previous_state_name);
  }

  entry function Waiting_main(previous_state_name: name) {
    this.startProcessingLastState();
  }

  function startProcessingLastState() {
    var last_state: name;
    
    if (parent.states_to_process.Size() <= 0) {
      parent.GotoState('Empty');

      return;
    }

    last_state = parent.states_to_process.PopBack();

    parent.GotoState(last_state);
  }
}