class SUIC_Manager {
  private var contexts: array<SU_InputContext>;
  private var layers: array<SU_LayeredInputContext>;

  public function init() {
    this.contexts.Clear();
    this.build(this.contexts);
  }

  public function onContextRegistered(context: SU_InputContext) {
    if (!this.contexts.Contains(context)) {
      this.contexts.PushBack(context);
    }

    this.buildInputLayersForContext(context);
  }

  public function onContextUnregistered(context: SU_InputContext) {
    this.resetInputsToVanilla();
    this.removeContextFromAllInputsLayers(context);
    this.buildInputLayersForAllContexts();
  }

  private function build(out contexts: array<SU_InputContext>) {}

  private function resetInputsToVanilla() {
    thePlayer.CreateInput();
  }

  private function buildInputLayersForAllContexts() {
    var i: int;

    for (i = 0; i < this.contexts.Size(); i += 1) {
      this.buildInputLayersForContext(this.contexts[i]);
    }
  }

  private function buildInputLayersForContext(context: SU_InputContext) {
    var actions: array<SU_InputContext_InputListenerInfo>;
    var layer: SU_LayeredInputContext;
    var i: int;

    actions = context.getInputListeners();

    for (i = 0; i < actions.Size(); i += 1) {
      layer = this.findOrCreateLayerForAction(actions[i].action);

      if (layer) {
        layer.tryAddContextActionListener(context, action);
      }
    }
  }

  private function removeContextFromAllInputsLayers(context: SU_InputContext) {
    var i: int;

    for (i = 0; i < this.layers.Size(); i += 1) {
      this.removeContextFromInputLayer(this.layers[i], context);
    }
  }

  private function removeContextFromInputLayer(
    layer: SU_LayeredInputContext,
    context: SU_InputContext
  ) {
    layer.tryRemoveContext(context);

    if (layer.isEmpty()) {
      this.layers.Remove(layer);
    }
  }

  private function findOrCreateLayerForAction(action: name): SU_LayeredInputContext {
    var layer: SU_LayeredInputContext;
    var i: int;

    for (i = 0; i < this.layers.Size(); i += 1) {
      layer = this.layers[i];

      if (layer.action == action) {
        return layer;
      }
    }

    // no layer was found for this action, create a new one then return it
    layer = new SU_LayeredInputContext in this;
    layer.init(action);
    this.layers.PushBack(layer);

    return layer;
  }

  //////////////////////////////////////////////////////////////////////////////
  // user interface logic

  private function refreshInputInterface(optional set_override: bool) {
    var feedback: CR4HudModuleControlsFeedback;
    var hud: CR4ScriptedHud;

    hud = (CR4ScriptedHud)theGame.GetHud();
    if (hud) {
      feedback = (CR4HudModuleControlsFeedback)hud.GetHudModule("ControlsFeedbackModule");

      if (feedback) {
        // setting this property will alert the @wrapMethod of this input context
        if (set_override) {
          feedback.su_input_context = this;
        }
        else {
          feedback.su_input_context = NULL;
        }

        feedback.UpdateInputContextActions();
      }
    }
  }
}