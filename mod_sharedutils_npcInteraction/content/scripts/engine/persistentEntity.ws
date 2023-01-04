/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



import class CPeristentEntity extends CEntity
{
	event OnBehaviorSnaphot() { return false; }

  // sharedutils - npcInteraction - BEGIN
	public saved var onInteractionEventListeners: array<SU_InteractionEventListener>;

	public function addInteractionEventListener(event_listener: SU_InteractionEventListener) {
		this.onInteractionEventListeners.PushBack(event_listener);
	}
	// sharedutils - npcInteraction - END
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
}