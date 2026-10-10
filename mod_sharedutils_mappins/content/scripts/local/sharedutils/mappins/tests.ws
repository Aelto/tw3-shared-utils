
exec function SU_MapPinTests() {
  SU_MapPinTest_0();
  SU_MapPinTest_1();
}

function SU_MapPinTest_0() {
  (new SU_MapPinsBuilder in thePlayer)
    .tag_prefix("SU_PinTest")
    // first pin
    .pin()
      .tag("first")
      .position(thePlayer.GetWorldPosition())
      .radius(20)
      .label("SU_PinTest label")
      .description("SU_PinTest description")
      .type("QuestAvailableBaW")
      .filtered_type("QuestAvailableBaW")
      .add()
    // second pin
    .pin()
      .tag("second")
      .position(thePlayer.GetWorldPosition() + Vector(10, 10, 0))
      .radius(5)
      .label("SU_PinTest label 2")
      .description("SU_PinTest description 2")
      .type("MonsterQuest")
      .filtered_type("MonsterQuest")
      .add()
    // update buffer
    .build();
}

// A night only pin next to the player, visible from 20:00 until 06:00.
function SU_MapPinTest_1() {
  (new SU_MapPinsBuilder in thePlayer)
    .tag_prefix("SU_PinTestNight")
    .pin()
      .tag("night")
      .position(thePlayer.GetWorldPosition() + Vector(-10, 10, 0))
      .radius(10)
      .label("SU_PinTest night label")
      .description("SU_PinTest night description, only shown from 20:00 to 06:00")
      .type("QuestAvailable")
      .filtered_type("QuestAvailable")
      .visible_between(20, 6)
      .add()
    .build();
}
