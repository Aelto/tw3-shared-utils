
class SU_Oneliner {
  /// the tag is not used in the display logic, but can be used to identify
  /// oneliners that belong to your code vs oneliners that don't.
  var tag: string;

  var id: int;
  var text: string;
  var visible: bool;
  var position: Vector;
  var offset: Vector;
  
  /// if set to a value above 0, will be used as a maximum render distance for
  /// the OL.
  var render_distance: int;

  default visible = true;

  function register() {
    var manager: SUOL_Manager;

    manager = SUOL_getManager();
    manager.createOneliner(this);
  }

  function unregister() {
    var manager: SUOL_Manager;

    manager = SUOL_getManager();
    manager.deleteOneliner(this);
  }

  function update() {
    var manager: SUOL_Manager;

    manager = SUOL_getManager();
    manager.updateOneliner(this);
  }

  //////////////////////////////////////////////////////////////////////////////

  public function setRenderDistance(value: int): SU_Oneliner {
    this.render_distance = value;

    return this;
  }

  public function setText(value: string): SU_Oneliner {
    this.text = value;

    return this;
  }

  public function setOffset(value: Vector): SU_Oneliner {
    this.offset = value;

    return this;
  }

  public function setTag(value: string): SU_Oneliner {
    this.tag = value;

    return this;
  }

  //////////////////////////////////////////////////////////////////////////////

  function getVisible(player_position: Vector): bool {
    if (this.render_distance <= 0) {
      return this.visible;
    }

    return VecDistanceSquared2D(
      player_position,
      this.getPosition()
    ) <= this.render_distance * this.render_distance;
  }

  function getPosition(): Vector {
    return this.position + this.offset;
  }

  public var cached_screen_position: Vector;
  function getScreenPosition(hud: CR4ScriptedHud, out screen_position: Vector): bool {
    var world_position: Vector;
    var result: bool;

    world_position = this.getPosition();
    result = SUOL_worldToScreenPosition(hud, world_position, screen_position);

    // the `cached_screen_position` could be set here, but in order to save an
    // if-check in this function that runs every frame and for every oneliner,
    // the value will be set in the `Render` state of the manager where it 
    // already performs an if-check on `result`. Ultimately saving us from doing
    // that duplicate check.
    // this.cached_screen_position = screen_position;

    return result;
  }
}
