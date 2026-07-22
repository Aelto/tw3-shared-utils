@addField(CInputManager) 
var sharedutils_oneliners: SUOL_Manager;

@addMethod(CInputManager)
public function getSharedutilsOnelinersManager(): SUOL_Manager {
  if (!this.sharedutils_oneliners) {
    SUOL_Logger("SUOL_getManager(), received null, instantiating instance");

    this.sharedutils_oneliners = new SUOL_Manager in this;
  }

  return this.sharedutils_oneliners;
}

@addMethod(CInputManager)
public function newSharedutilsOnelinersManager() 
{
  getSharedutilsOnelinersManager().deleteAllOneliners();
  this.sharedutils_oneliners = new SUOL_Manager in this;
}

@wrapMethod(CR4Game)
function OnAfterLoadingScreenGameStart()
{
  wrappedMethod();
  theInput.newSharedutilsOnelinersManager();
}