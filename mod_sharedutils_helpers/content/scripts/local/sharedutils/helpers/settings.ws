
function SUH_settingsWrapper(): CInGameConfigWrapper {
  return theGame.GetInGameConfigWrapper();
}

function SUH_settingsMenu(menu: name, optional wrapper: CInGameConfigWrapper): SUH_Menu {
  if (!wrapper) {
    wrapper = SUH_settingsWrapper();
  }

  return SUH_Menu(wrapper, menu);
}

function SUH_settingsRead(menu: SUH_Menu, field: name): string {
  return menu.wrapper.GetVarValue(menu.menu, field);
}

function SUH_settingsWrite(menu: SUH_Menu, field: name, value: string) {
  menu.wrapper.SetVarValue(field, value);
}



function SUH_settingsString(menu: name, field: name, optional wrapper: CInGameConfigWrapper): string {
  return SUH_settingsRead(SUH_settingsMenu(menu, wrapper), field);
}

function SUH_settingsInt(menu: name, field: name, optional wrapper: CInGameConfigWrapper): int {
  return StringToInt(SUH_settingsString(menu, field, wrapper));
}

function SUH_settingsFloat(menu: name, field: name, optional wrapper: CInGameConfigWrapper): float {
  return StringToFloat(SUH_settingsString(menu, field, wrapper));
}

function SUH_settingsBool(menu: name, field: name, optional wrapper: CInGameConfigWrapper): bool {
  return SUH_settingsString(menu, field, wrapper);
}



struct SUH_Menu {
  var wrapper: CInGameConfigWrapper,
  var menu: name;
}
