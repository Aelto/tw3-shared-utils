@addField(CR4Player) 
var sharedutils_oneliners: SUOL_Manager;

@addMethod(CR4Player)
public function getSharedutilsOnelinersManager(): SUOL_Manager {
  if (!this.sharedutils_oneliners) {
    SUOL_Logger("SUOL_getManager(), received null, instantiating instance");

    this.sharedutils_oneliners = new SUOL_Manager in this;
  }

  return this.sharedutils_oneliners;
}
