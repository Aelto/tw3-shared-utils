
/// A oneliner that follows the world coordinates of an entity
class SU_OnelinerStatus extends SU_OnelinerScreen {
  function register() {
    var manager: SUOL_Manager;

    manager = SUOL_getManager();
    manager.createOnelinerStatus(this);
  }

  function unregister() {
    var manager: SUOL_Manager;

    manager = SUOL_getManager();
    manager.deleteOnelinerStatus(this);
  }
}
