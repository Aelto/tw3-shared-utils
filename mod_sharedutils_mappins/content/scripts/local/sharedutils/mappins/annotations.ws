@addField(CR4Player)
var sharedutils_mappins: SUMP_Manager;

@addMethod(CR4Player)
function getSharedutilsMappinsManager(): SUMP_Manager {
  if (!this.sharedutils_mappins) {
    SUMP_Logger("SUMP_getManager(), received null, instantiating instance");
    this.sharedutils_mappins = new SUMP_Manager in this;
  }

  return this.sharedutils_mappins;
}


@wrapMethod(CR4MapMenu)
function UpdateUserMapPins( out flashArray : CScriptedFlashArray, indexToUpdate : int ) : void {
  wrappedMethod(flashArray, indexToUpdate);

  if (indexToUpdate <= -1) {
    SU_updateCustomMapPins(flashArray, GetMenuFlashValueStorage(), m_shownArea);
  }
}

@wrapMethod(CR4MapMenu)
function OnStaticMapPinUsed( pinTag : name, areaId : int) {
  if (SUMP_onPinUsed(pinTag, areaId)) {
    return true;
  }

  return wrappedMethod(pinTag, areaId);
}

@wrapMethod(CR4HudModuleMinimap2)
function OnConfigUI() {
  SU_updateMinimapPins();

  return wrappedMethod();
}
