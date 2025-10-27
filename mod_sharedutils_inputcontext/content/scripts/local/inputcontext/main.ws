@wrapMethod(CR4Player)


class SUIC_Example extends SU_InputContext {
  private function build() {
    super.build();

    this.withInput('SpawnHorse', 'OnHorseCalled', "Send a UI message");
  }

  event OnHorseCalled(action: SInputAction) {
    GetWitcherPlayer().DisplayHudMessage("It's my input instead!");
    this.unregister();
  }
}

exec function suicexample() {
  var context: SUIC_Example;

  context = new SUIC_Example in theInput;
  context.register();
}