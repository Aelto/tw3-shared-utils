function SU_oneliner(text: string, position: Vector): SU_Oneliner {
  var oneliner: SU_Oneliner;

  oneliner = new SU_Oneliner in thePlayer;
  oneliner.text = text;
  oneliner.position = position;
  oneliner.register();

  return oneliner;
}

function SU_onelinerScreen(text: string, position: Vector): SU_OnelinerScreen {
  var oneliner: SU_OnelinerScreen;

  oneliner = new SU_OnelinerScreen in thePlayer;
  oneliner.text = text;
  oneliner.position = position;
  oneliner.register();

  return oneliner;
}

function SU_onelinerEntity(text: string, entity: CEntity): SU_OnelinerEntity {
  var oneliner: SU_OnelinerEntity;

  oneliner = new SU_OnelinerEntity in thePlayer;
  oneliner.text = text;
  oneliner.entity = entity;
  oneliner.register();

  return oneliner;
}
