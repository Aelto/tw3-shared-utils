
///
statemachine class SUOL_Manager extends SU_StorageItem {
  default tag = "SUOL_Manager";

  /// an internal counter
  private var oneliner_counter: int;

  /// A list of all the active oneliners
  protected var oneliners: array<SU_Oneliner>;

  /// A garbage type of array that stores the IDs of old, deleted sprites so
  /// that when asking for a new ID it returns an old recycled one instead.
  private var oneliners_garbage: array<int>;

  //////////////////////////////////////////////////////////////////////////////
  // statemachine workflow code:

  protected var module_oneliners: CR4HudModuleOneliners;
  protected var module_flash: CScriptedFlashSprite;
  protected var module_hud: CR4ScriptedHud;

  private var fxCreateOnelinerSFF: CScriptedFlashFunction;
  private var fxRemoveOnelinerSFF: CScriptedFlashFunction;

  private function initialize() {
    this.module_hud = (CR4ScriptedHud)theGame.GetHud();
    this.module_oneliners = (CR4HudModuleOneliners)(this.module_hud.GetHudModule( "OnelinersModule" ));
    this.module_flash = this.module_oneliners.GetModuleFlash();

		this.fxCreateOnelinerSFF 	= this.module_flash.GetMemberFlashFunction( "CreateOneliner" );
		this.fxRemoveOnelinerSFF 	= this.module_flash.GetMemberFlashFunction( "RemoveOneliner" );
  }

  private function getNewId(): int {
    var id: int;

    if (this.oneliners_garbage.Size() > 0) {
      id = this.oneliners_garbage.PopBack();
    }
    else {
      this.oneliner_counter += 1;
      id = this.oneliner_counter;
    }

    return id;
  }

  //////////////////////////////////////////////////////////////////////////////
  // public API:

  public function createOneliner(oneliner: SU_Oneliner) {
    var should_initialize_and_render: bool;

    should_initialize_and_render = this.GetCurrentStateName() != 'Render';

    if (should_initialize_and_render) {
      this.initialize();
    }

    oneliner.id = this.getNewId();
    this.updateOneliner(oneliner);
    this.oneliners.PushBack(oneliner);

    if (should_initialize_and_render) {
      this.GotoState('Render');
    }
  }

  /// Updates the flash values with the oneliner's new/current text
  public function updateOneliner(oneliner: SU_Oneliner) {
    this.fxRemoveOnelinerSFF.InvokeSelfOneArg(FlashArgInt(oneliner.id));
    this.fxCreateOnelinerSFF.InvokeSelfTwoArgs(
      FlashArgInt(oneliner.id),
      FlashArgString(oneliner.text)
    );
  }

  public function deleteOneliner(oneliner: SU_Oneliner) {
    this.oneliners.Remove(oneliner);
    this.oneliners_garbage.PushBack(oneliner.id);
    this.fxRemoveOnelinerSFF.InvokeSelfOneArg(FlashArgInt(oneliner.id));
  }

  public function findByTag(tag: string): array<SU_Oneliner> {
    var output: array<SU_Oneliner>;
    var i: int;

    for (i = 0; i < this.oneliners.Size(); i += 1) {
      if (this.oneliners[i].tag == tag) {
        output.PushBack(this.oneliners[i]);
      }
    }

    return output;
  }

  public function findByTagPrefix(tag: string): array<SU_Oneliner> {
    var output: array<SU_Oneliner>;
    var i: int;

    for (i = 0; i < this.oneliners.Size(); i += 1) {
      if (StrStartsWith(this.oneliners[i].tag, tag)) {
        output.PushBack(this.oneliners[i]);
      }
    }

    return output;
  }

  public function deleteByTag(tag: string): array<SU_Oneliner> {
    var output: array<SU_Oneliner>;
    var i: int;

    output = this.findByTag(tag);
    for (i = 0; i < output.Size(); i += 1) {
      this.deleteOneliner(output[i]);
    }

    return output;
  }

  public function deleteByTagPrefix(tag: string): array<SU_Oneliner> {
    var output: array<SU_Oneliner>;
    var i: int;

    output = this.findByTagPrefix(tag);
    for (i = 0; i < output.Size(); i += 1) {
      this.deleteOneliner(output[i]);
    }

    return output;
  }
}

