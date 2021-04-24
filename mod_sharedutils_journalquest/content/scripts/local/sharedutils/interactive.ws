
class SU_InteractivePoint extends W3MonsterClue {
  /**
   * Change it and geralt will play an animation OnInteraction,
   * possible values:
   * - PEA_SlotAnimation
   * - PEA_Meditation
   * - PEA_ExamineGround
   * - PEA_ExamineEyeLevel
   * - PEA_SmellHigh
   * - PEA_SmellMid
   * - PEA_SmellLow
   * - PEA_InspectHigh
   * - PEA_InspectMid
   * - PEA_InspectLow
   * - PEA_IgniLight
   * - PEA_AardLight
   * - PEA_SetBomb
   * - PEA_PourPotion
   * - PEA_DispelIllusion
   * - PEA_GoToSleep
   */
  default interactionAnim = PEA_None;

  event OnInteraction( actionName : string, activator : CEntity  ) {
    if (this.interactionAnim != PEA_None) {
      this.PlayInteractionAnimation();
    }
  }

  event OnFocusModeEnabled( enabled : bool ) {
    if (enabled) {
      PlayEffect('remains_highlight');
    }
    else {
      StopEffect('remains_highlight');
    }
	}
}