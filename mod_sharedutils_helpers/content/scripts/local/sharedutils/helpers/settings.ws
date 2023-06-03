
function SUS(): SUS_Wrapper {
  return (new SUS_Wrapper in thePlayer).init();
}

class SUS_Wrapper {
  private wrapper: CInGameConfigWrapper;

  function init(): SUS_Wrapper {
    this.wrapper = theGame.GetInGameConfigWrapper();

    return this;
  }

  function string(menu: name, field: name): string {
    return wrapper.GetVarValue(menu, field);
  }

  function int(menu: name, field: name): int {
    return StringToInt(this.string(menu, field));
  }

  function float(menu: name, field: name): float {
    return StringToFloat(this.string(menu, field));
  }

  function bool(menu: name, field: name): bool {
    return this.string(menu, field);
  }

  function write(menu: name, field: name, value: string) {
    this.wrapper.SetVarValue(menu, field, value);
  }
}
