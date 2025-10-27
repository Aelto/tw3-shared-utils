struct SU_InputContext_InputListenerInfo {
  var event_name: name;
  var action: name;
  var label: string;
}

class SU_InputContext extends IScriptable {
  public function register() {
    this.build();
    this.registerAllInputs();
    this.refreshInputInterface(true);
  }

  public function unregister() {
    this.unregisterAllInputs();
    this.refreshInputInterface(false);
  }

  protected function build() {
    this.input_listeners.Clear();
  }

  //////////////////////////////////////////////////////////////////////////////
  // inputs logic:

  private var input_listeners: array<SU_InputContext_InputListenerInfo>;
  protected function withInput(action: name, event_name: name, label: string) {
    this.input_listeners
      .PushBack(SU_InputContext_InputListenerInfo(event_name, action, label));
  }

  private function unregisterAllInputs() {
    var i: int;

    for (i = 0; i < this.input_listeners.Size(); i += 1) {
      theInput.UnregisterListener(this, this.input_listeners[i].action);
    }
  }

  private function registerAllInputs(optional action: name) {
    var i: int;

    for (i = 0; i < this.input_listeners.Size(); i += 1) {
      if (action != '' && action != this.input_listeners[i].action) {
        continue;
      }

      theInput.RegisterListener(
        this,
        this.input_listeners[i].event_name,
        this.input_listeners[i].action
      );
    }
  }

  public function getInputListeners(): array<SU_InputContext_InputListenerInfo> {
    return this.input_listeners;
  }
}