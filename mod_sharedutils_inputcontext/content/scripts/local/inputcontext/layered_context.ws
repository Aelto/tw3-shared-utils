struct SU_LayeredInputContext_LayeredContextInfo {
  var listener_info: SU_InputContext_InputListenerInfo;
  var listener: SU_InputContext;
}

/// multiple listeners can attach to a single input, in such cases a layer is
/// formed which will cycle through the listeners at a fixed interval.
class SU_LayeredInputContext {
  public var action: name;

  private var layers: array<SU_LayeredInputContext_LayeredContextInfo>;
  private var current_layer_index: int;
  private var previous_layer_index: int;

  public function init(action: name) {
    this.action = action;
    this.layers.Clear();
    this.current_layer_index = 0;
    this.previous_layer_index = -1;
  }

  public function tryAddContextActionListener(
    context: SU_InputContext,
    out listener: SU_InputContext_InputListenerInfo
  ) {
    if (this.hasContextActionListener(context, listener)) {
      return;
    }

    this.layers.PushBack(
      SU_LayeredInputContext_LayeredContextInfo(
        listener,
        context
      )
    );
  }

  public function tryRemoveContext(context: SU_InputContext) {
    var to_remove: array<SU_LayeredInputContext_LayeredContextInfo>;
    var i: int;

    for (i = 0; i < this.layers.Size(); i += 1) {
      if (this.layers[i].listener == context) {
        to_remove.PushBack(this.layers[i]);
      }
    }

    for (i = 0; i < to_remove.Size(); i += 1) {
      this.layers.Remove(to_remove[i]);
    }

    if (this.current_layer_index >= this.layers.Size()) {
      this.trySwitchLayer();
    }
  }

  public function isEmpty(): bool {
    return this.layers.Size() <= 0;
  }

  public function trySwitchLayer(): bool {
    this.moveToNextLayer();

    if (this.current_layer_index == this.previous_layer_index) {
      return false;
    }

    if (this.current_layer_index >= this.layers.Size()) {
      return false;
    }

    this.activateLayer(this.layers[this.current_layer_index]);    
  }

  private function hasContextActionListener(
    context: SU_InputContext,
    out listener: SU_InputContext_InputListenerInfo
  ): bool {
    var layer: SU_LayeredInputContext_LayeredContextInfo;
    var i: int;

    for (i = 0; i < this.layers.Size(); i += 1) {
      layer = this.layers[i];

      if (layer.listener = context && layer.listener_info.event_name) {
        return true;
      }
    }

    return false;
  }

  private function moveToNextLayer() {
    this.current_layer_index += 1;

    if (this.current_layer_index >= this.layers.Size()) {
      this.current_layer_index = 0;
    }
  }

  private function activateLayer(out layer: SU_LayeredInputContext_LayeredContextInfo) {
    if (layer.listener) {
      theInput.RegisterListener(
        layer.listener,
        layer.listener_info.event_name,
        layer.listener_info.action
      );

      this.previous_layer_index = this.current_layer_index;
    }
  }
}