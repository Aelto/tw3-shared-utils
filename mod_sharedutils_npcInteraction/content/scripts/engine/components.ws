/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/








import class CComponent extends CNode
{
	
	import final function GetEntity() : CEntity;
	
	
	import final function IsEnabled() : bool;
	
	
	import final function SetEnabled( flag : bool );
	
	
	import final function SetPosition( position : Vector );
	
	
	import final function SetRotation( rotation : EulerAngles );
	
	
	import final function SetScale( scale : Vector );
	
	
	import final function HasDynamicPhysic() : bool;
	import final function HasCollisionType( collisionTypeName : name, optional actorIndex : int, optional shapeIndex : int ) : bool;
	import final function GetPhysicalObjectLinearVelocity( optional actorIndex : int ) : Vector;
	import final function GetPhysicalObjectAngularVelocity( optional actorIndex : int ) : Vector;
	import final function SetPhysicalObjectLinearVelocity( velocity : Vector, optional actorIndex : int ) : bool;
	import final function SetPhysicalObjectAngularVelocity( velocity : Vector, optional actorIndex : int ) : bool;
	import final function GetPhysicalObjectMass( optional actorIndex : int ) : Float; 
	import final function ApplyTorqueToPhysicalObject( torque : Vector, optional actorIndex : int );
	import final function ApplyForceAtPointToPhysicalObject( force : Vector, point : Vector, optional actorIndex : int );
	import final function ApplyLocalImpulseToPhysicalObject( impulse : Vector, optional actorIndex : int );
	import final function ApplyTorqueImpulseToPhysicalObject( impulse : Vector, optional actorIndex : int );
	import final function GetPhysicalObjectBoundingVolume( out box : Box ) : bool;
	
	import final function SetShouldSave( shouldSave : bool );
	
	
	public function SignalCustomEvent( eventName : name )
	{
	}
}

struct SAnimMultiplyCauser
{
	saved var id : int;
	saved var mul : float;
};





import class CInteractionAreaComponent extends CComponent
{
	import var performScriptedTest : bool;

	import final function GetRangeMin() : float;
	import final function GetRangeMax() : float;
	
	import final function SetRanges( rangeMin : float, rangeMax : float, height : float );
	import final function SetRangeAngle( rangeAngle : int );
	
	import final function SetCheckLineOfSight( flag : bool );
}





import class CInteractionComponent extends CInteractionAreaComponent
{
	import protected var isEnabledInCombat : bool;
	import protected var shouldIgnoreLocks : bool;
	
	private editable var isEnabledOnHorse : bool;
	default isEnabledOnHorse = false;
	
	editable var aimVector : Vector;
	editable var iconOffset	: Vector;
	
	editable var iconOffsetSlotName	: name;
	default iconOffsetSlotName = 'icon';

	hint aimVector = "Offset from component center for camera to check whether the component is visible";
	hint iconOffset = "Offset from component center where the interaction icon will be shown";
	hint iconOffsetSlotName = "If there is a slot with the name, the icon offset position will match this slot position";
	
	public function IsEnabledOnHorse() : bool { return isEnabledOnHorse; }

	public function IsEnabledInCombat() : bool 	{return isEnabledInCombat;}

	public function ShouldIgnoreLocks() : bool 	{return shouldIgnoreLocks;}

	
	import final function GetActionName() : string;

	
	import final function SetActionName( actionName : string );

	
	import final function GetInteractionFriendlyName() : string;

	import final function GetInteractionKey() : int;
	
	import final function GetInputActionName() : name;
	
	
	
	public function EnableInCombat( enable : bool )
	{
		isEnabledInCombat = enable;
	}
	
	public final function SetIconOffset( offset : Vector )
	{
		iconOffset = offset;
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
    // sharedutils - npcInteraction - BEGIN
		if (!SU_NpcInteraction_runAllInteractionListeners(actionName, activator, this.GetEntity())) {
			return false;
		}
		// sharedutils - npcInteraction - END
		
		if ( theGame.GetInteractionsManager().GetActiveInteraction() == this )
		{
			if ( thePlayer.IsInCombat() && !thePlayer.IsSwimming() )
			{
				if ( IsEnabledInCombat() )
					return false;
				else
					return true;
			}
			else if ( thePlayer.IsInCombatAction() || thePlayer.IsCrossbowHeld() )
				return true;
			else
				return false;
		}
		else
			return true;
		
	}
	
	public final function UpdateIconOffset()
	{
		var l_entity 			: CEntity;
		var l_localToWorld		: Matrix;
		var l_worldToLocal		: Matrix;
		var l_slotMatrix		: Matrix;
		var l_slotWorldPos		: Vector;
		var l_offset			: Vector;
		var l_box				: Box;		
		
		if( !IsNameValid( iconOffsetSlotName ) ) return;
		
		l_entity = GetEntity();
		
		if( l_entity.CalcEntitySlotMatrix( iconOffsetSlotName, l_slotMatrix ) )
		{
			l_localToWorld 	= GetLocalToWorld();
			l_worldToLocal 	= MatrixGetInverted( l_localToWorld );
			
			l_slotWorldPos 	= MatrixGetTranslation( l_slotMatrix );
			l_offset 		= VecTransform( l_worldToLocal , l_slotWorldPos );
			
			SetIconOffset( l_offset );
		}
	}
}





import class CAnimatedComponent extends CComponent
{
	var nextFreeAnimMultCauserId : int;
		default nextFreeAnimMultCauserId = 0;
	
	var animationMultiplierCausers : array<SAnimMultiplyCauser>;
	
	
	import final latent function ActivateBehaviors( names : array< name > ) : bool;
	
	
	import final latent function AttachBehavior( instanceName : name ) : bool;
	
	
	import final function DetachBehavior( instanceName : name ) : bool;
	
	
	import final function GetBehaviorVariable( varName : name ) : float;
	
	
	import final function GetBehaviorVectorVariable( varName : name ) : Vector;
	
	
	import final function SetBehaviorVariable( varName : name, varValue : float ): bool;
	
	
	import final function SetBehaviorVectorVariable( varName : name, varValue : Vector ) : bool;

	
	import final function DisplaySkeleton( bone : bool, optional axis : bool, optional names : bool );
	
	
	import final function GetAnimationTimeMultiplier() : float;
	
	
	import final function DontUpdateByOtherAnimatedComponent();
	import final function UpdateByOtherAnimatedComponent( slaveComponent : CAnimatedComponent );
	
	
	
	
	
	import final function SetAnimationTimeMultiplier( mult : float );
		
	
	public function SetAnimationSpeedMultiplier(mul : float) : int
	{
		var causer : SAnimMultiplyCauser;
		var finalMul : float;
				
		
		causer.mul = mul;
		causer.id = nextFreeAnimMultCauserId;
		
		nextFreeAnimMultCauserId += 1;
		
		animationMultiplierCausers.PushBack(causer);
				
		
		SetAnimationTimeMultiplier(CalculateFinalAnimationSpeedMultiplier());
		
		return causer.id;
	}
	
	
	private function CalculateFinalAnimationSpeedMultiplier() : float
	{
		if(animationMultiplierCausers.Size() > 0)
			return animationMultiplierCausers[animationMultiplierCausers.Size()-1].mul;
		
		return 1;
	}
	
	
	public function ResetAnimationSpeedMultiplier(id : int)
	{
		var i,size : int;
		
		size = animationMultiplierCausers.Size();
		if(size == 0)
			return;	
		
		for(i=size-1; i>=0; i-=1)
			if(animationMultiplierCausers[i].id == id)
				animationMultiplierCausers.Erase(i);
				
		if(animationMultiplierCausers.Size()+1 != size)
		{
			LogAssert(false, "CAnimatedComponent.ResetAnimationMultiplier: invalid causer ID passed, nothing removed!");
			return;
		}
		
		SetAnimationTimeMultiplier(CalculateFinalAnimationSpeedMultiplier());
	}
	
	
	import final function GetMoveSpeedAbs() : float;
	
	
	import final function GetMoveSpeedRel() : float;

	
	import final function RaiseBehaviorEvent( eventName : name ) : bool;
	
	
	import final function RaiseBehaviorForceEvent( eventName : name ) : bool;
	
	
	import final function FindNearestBoneWS( out position : Vector ) : int; 
	
	import final function FindNearestBoneToEdgeWS( a : Vector, b : Vector ) : int; 

	
	import final function GetCurrentBehaviorState( optional instanceName : name ) : string;
	
	
	import final function FreezePose();
	
	
	import final function UnfreezePose();
	
		
	import final function FreezePoseFadeIn( fadeInTime : float );
	
	
	import final function UnfreezePoseFadeOut( fadeOutTime : float );
	
	
	import final function HasFrozenPose() : bool;
	
	
	import final function SyncTo( slaveComponent : CAnimatedComponent, ass : SAnimatedComponentSyncSettings ) : bool;
	
	
	import final function UseExtractedMotion() : bool;
	
	
	import final function SetUseExtractedMotion( use : bool ); 
	
	
	import final function HasRagdoll() : bool;

	import final function GetRagdollBoneName( actorIndex : int ) : name;

	
	import final function StickRagdollToCapsule( stick : bool);
	
	
	import final function PlaySlotAnimationAsync( animation : name, slotName : name, optional settings : SAnimatedComponentSlotAnimationSettings ) : bool;
	
	
	import final function PlaySkeletalAnimationAsync ( animation : name, optional looped : bool ) : bool;

	import final function GetBoneMatrixMovementModelSpaceInAnimation( boneIndex : int, animation : name, time : float, deltaTime : float, out boneAtTimeMS : Matrix, out boneWithDeltaTimeMS : Matrix );
}



import class CDropPhysicsComponent extends CComponent
{
	import final function DropMeshByName( meshName : string,
										  optional direction : Vector ,
     								      optional curveName : name  ) : bool;
	import final function DropMeshByTag( meshTag : name,
                                          optional direction : Vector ,
     									  optional curveName : name  ) : bool;
}



enum EDismembermentEffectTypeFlags
{ 
	DETF_Base		= 1, 
	DETF_Igni		= 2, 
	DETF_Aaard		= 4, 
	DETF_Yrden		= 8, 
	DETF_Quen		= 16,
	DETF_Mutation6	= 32, 
};



import class CDismembermentComponent extends CComponent
{
	import final function IsWoundDefined( woundName : name ) : bool;
	import final function SetVisibleWound( woundName : name, optional spawnEntity : bool, optional createParticles : bool,
															 optional dropEquipment : bool, optional playSound : bool,
															 optional direction : Vector, optional playedEffectsMask : int );
	import final function ClearVisibleWound();
	import final function GetVisibleWoundName() : name;
	import final function CreateWoundParticles( woundName : name ) : bool;
	import final function GetNearestWoundName( positionMS : Vector, normalMS : Vector,
											   optional woundTypeFlags : EWoundTypeFlags  ) : name;
	import final function GetNearestWoundNameForBone( boneIndex : int, normalWS : Vector,
													  optional woundTypeFlags : EWoundTypeFlags  ) : name;
	import final function GetWoundsNames( out names : array< name >,
										  optional woundTypeFlags : EWoundTypeFlags  );
	import final function IsExplosionWound( woundName : name ) : bool;
	import final function IsFrostWound( woundName : name ) : bool;
	import final function GetMainCurveName( woundName : name ) : name;
}





import class CBoundedComponent extends CComponent
{
	
	import final function GetBoundingBox() : Box;
}

import class CAreaComponent extends CBoundedComponent
{
	
	
	
	
	import final function TestEntityOverlap( ent : CEntity ) : Bool;
	
	import final function TestPointOverlap( point : Vector ) : Bool;
	
	import final function GetWorldPoints( out points : array< Vector > );
}





import class CDrawableComponent extends CBoundedComponent
{
	
	import final function IsVisible() : bool;
	
	
	import final function SetVisible( flag : bool );

	

	
	
	import final function SetCastingShadows ( flag : bool );

	
	public function GetObjectBoundingVolume( out box : Box ) : bool
	{
		return GetPhysicalObjectBoundingVolume( box );
	}	
}





import class CRigidMeshComponent extends CStaticMeshComponent
{
	
	import function EnableBuoyancy( enable : bool ) : bool;
}





import class CDecalComponent extends CDrawableComponent
{
}





import class CNormalBlendComponent extends CComponent
{
}





import class CSpriteComponent extends CComponent
{
}





import class CWayPointComponent extends CSpriteComponent 
{
}





enum ETriggerChannels
{
	TC_Default			= 1,			
	TC_Player			= 2,			
	TC_Camera			= 4,			
	TC_NPC				= 8,			
	TC_SoundReverbArea	= 16,			
	TC_SoundAmbientArea	= 32,			
	TC_Quest			= 64,			
	TC_Projectiles		= 128,			
	TC_Horse			= 256,			
	TC_Custom0			= 65536,		
	TC_Custom1			= 131072,		
	TC_Custom2			= 262144,		
	TC_Custom3			= 524288,		
	TC_Custom4			= 1048576,		
	TC_Custom5			= 2097152,		
	TC_Custom6			= 4194304,		
	TC_Custom7			= 8388608,		
	TC_Custom8			= 16777216,		
	TC_Custom9			= 33554432,		
	TC_Custom10			= 67108864,		
	TC_Custom11			= 134217728,	
	TC_Custom12			= 268435456,	
	TC_Custom13			= 536870912,	
	TC_Custom14			= 1073741824,	
};





import class CTriggerAreaComponent extends CAreaComponent
{
	
	import final function SetChannelMask( includedChannels, excludedChannes : int );
	
	
	import final function AddIncludedChannel( channel : ETriggerChannels );

	
	import final function RemoveIncludedChannel( channel : ETriggerChannels );

	
	import final function AddExcludedChannel( channel : ETriggerChannels );

	
	import final function RemoveExcludedChannel( channel : ETriggerChannels );
	
	
	public function GetGameplayEntitiesInArea( out entities : array< CGameplayEntity >, optional range : float, optional onlyActors : bool )
	{
		var i, curr, size : int;
		var source : CEntity;
		var box : Box;
		
		box = GetBoundingBox();
		if ( range == 0 )
		{
			range = GetBoxRange( box );
		}
		else 
		{
			range = MinF( range, GetBoxRange( box ) );
		}
	
		source = GetEntity();
		if ( onlyActors )
		{
			FindGameplayEntitiesInRange( entities, source, range, 1000, , FLAG_ExcludeTarget + FLAG_OnlyActors, (CGameplayEntity)source );
		}
		else
		{
			FindGameplayEntitiesInRange( entities, source, range, 1000, , FLAG_ExcludeTarget, (CGameplayEntity)source );
		}
		
		size = entities.Size();
		curr = 0;
		for ( i = 0; i < size; i+=1 )
		{
			if ( TestEntityOverlap( entities[ i ] ) )
			{
				entities[ curr ] = entities[ i ];
				curr += 1;
			}
		}
		entities.Resize( curr );
	}
}





import class CTriggerActivatorComponent extends CComponent
{
	
	import final function SetRadius( radius : float );
	
	
	import final function SetHeight( height : float );
	
	
	import final function GetRadius() : float;
	
	
	import final function GetHeight() : float;
	
	
	import final function AddTriggerChannel( channel : ETriggerChannels );
	
	
	import final function RemoveTriggerChannel( channel : ETriggerChannels );
}





import class CCombatDataComponent extends CComponent
{
	
	import final function GetAttackersCount() : int;
	import final function GetTicketSourceOwners( out actors : array< CActor >, ticketName : name );
	import final function HasAttackersInRange( range : float ) : bool;
	
	
	import final function TicketSourceOverrideRequest( ticketName : name, ticketsCountMod : int, minimalImportanceMod : float ) : int;
	
	import final function TicketSourceClearRequest( ticketName : name, requestId : int ) : bool;
	
	import final function ForceTicketImmediateImportanceUpdate( ticketName : name );
	
}





import class CDestructionSystemComponent extends CDrawableComponent
{
	import final function GetFractureRatio() : float;
	import final function ApplyFracture() : bool;
	import final function IsDestroyed() : bool;
	import final function IsObstacleDisabled() : bool;
	
	
	public function GetObjectBoundingVolume( out box : Box ) : bool
	{
		
		box = GetBoundingBox();
		if ( box.Min != box.Max )
		{
			return true;
		}
		
		return GetPhysicalObjectBoundingVolume( box );
	}	
}





import class CDestructionComponent extends CMeshTypeComponent
{
	import final function ApplyFracture() : bool;
	import final function IsDestroyed() : bool;
	import final function IsObstacleDisabled() : bool;
	
	
	public function GetObjectBoundingVolume( out box : Box ) : bool
	{
		
		box = GetBoundingBox();
		if ( box.Min != box.Max )
		{
			return true;
		}
		
		return GetPhysicalObjectBoundingVolume( box );
	}	
}

import class CSoundAmbientAreaComponent extends CSoftTriggerAreaComponent
{

}





import class CClothComponent extends CMeshTypeComponent
{
	import final function SetSimulated( value : bool );
	import final function SetMaxDistanceScale( scale : float );
	import final function SetFrozen( frozen : bool );
}
