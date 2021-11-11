//---=== modFriendlyHUD ===---
struct SMod3DMarker
{
	var visibleType		: name;		//map pin visible type
	var isDiscovered	: bool;		//is discovered
	var isKnown			: bool;		//is known
	var isDisabled		: bool;		//is disabled
	var isHighlighted	: bool;		//is active quest objective
	var isActiveQuest	: bool;		//is active quest
	var lvlDiff			: EQuestLevel; //player - quest lvl diff
	var description		: string;	//map pin short description (quest name, merchant type, etc)
	var position		: Vector;	//map pin world position
	var distance		: float;	//distance from player
	var text			: string;	//text/icon to display
	//three oneliners per marker seems excessive, but it's the only way to avoid flickering
	var onelinerID		: int;		//oneliner ID
	var distOnelinerID	: int;		//distance text oneliner ID
	var descrOnelinerID	: int;		//description text oneliner ID
	var screenPosition	: Vector;	//screen position
	var onScreen		: bool;		//is on screen
	var offscreenText	: string;	//text/icon to display if offscreen
	//display conditions
	var force			: bool;		//force show marker (respects max distance, ignores visibility)
	var pin				: bool;		//pin marker (ignores max distance, respects visibility)
};

enum EMarkersDisplayMode
{
	MDM_WS,
	MDM_Always,
	MDM_Never
};

enum EMarkersIconType
{
	MIT_Icon,
	MIT_Icon_bw,
	MIT_Text,
	MIT_Text_bw
};

enum EMarkersVisibility
{
	MV_Show,
	MV_Hide,
	MV_Pin,
	MV_Force
};

enum EQuestLevel
{
	QL_NORMAL,
	QL_HIGH,
	QL_LOW
};

//this event triggers when map pin entity gets changed, like noticeboard changing from full
//to empty; undiscovered pin changing to discovered, etc.
//it's not triggered when quest is activated/deactivated or when user map pin is added
class CModMarkersListener extends IGlobalEventScriptedListener
{
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if( eventCategory == GetGlobalEventCategory( SEC_OnMapPinChanged ) )
		{
			//theGame.witcherLog.AddMessage( "OnMapPinChanged" );
			Mod3DMarkersSignalCache3DMarkers( true );
		}
	}
}

class CModMarkers
{
	var config								: CModFriendlyHUDConfig;
	var hud 								: CR4ScriptedHud;
	var module								: CR4HudModuleOneliners;
	var isGeralt							: bool;
	
	var bIconCurrentlyShown					: bool; default bIconCurrentlyShown = false;
	var bAltTextCurrentlyShown				: bool; default bAltTextCurrentlyShown = false;
	var bDescriptionCurrentlyShown			: bool; default bDescriptionCurrentlyShown = false;
	var bDistanceCurrentlyShown				: bool; default bDistanceCurrentlyShown = false;
	var bCompassCurrentlyShown				: bool; default bCompassCurrentlyShown = false;
	
	var isIconFadingOut						: bool; default isIconFadingOut = false;
	var isDescriptionFadingOut				: bool; default isDescriptionFadingOut = false;
	var isDistanceFadingOut					: bool; default isDistanceFadingOut = false;
	var isCompassFadingOut					: bool; default isCompassFadingOut = false;
	
	var iconFadeOutTime						: float;
	var descriptionFadeOutTime				: float;
	var distanceFadeOutTime					: float;
	var compassFadeOutTime					: float;
	
	var marginCenter						: Vector;
	var marginLeftTop						: Vector;
	var marginRightBottom					: Vector;
	
	var timeDelta							: float;
	var markersAlpha						: float;
	
	var onelinersMaxID						: int; default onelinersMaxID = -1;
	var prevOnelinersMaxID					: int; default prevOnelinersMaxID = -1;
	
	const var MARKERS_START_ID				: int; default MARKERS_START_ID = 100500;
	const var MARKERS_END_ID				: int; default MARKERS_END_ID = 100899;
	const var COMPASS_START_ID				: int; default COMPASS_START_ID = 100900;
	const var COMPASS_END_ID				: int; default COMPASS_END_ID = 100909;
	
	var projOffset, descrOffset, distOffset	: float;
	
	var cached3DMarkersStatic				: array< SMod3DMarker >;
	var cached3DMarkersDynamic				: array< SMod3DMarker >;
	var cached3DMarkersTracked				: array< SMod3DMarker >;
	var cachedQuestPins						: array< SCommonMapPinInstance >;
	var cachedQuestLevels					: array< EQuestLevel >;
	var cachedWorldPath						: string;
	var cachedNumPins						: int;
	var isDirty								: bool; default isDirty = false;
	var cacheQuestPins						: bool; default cacheQuestPins = false;
	var delayedCacheTime					: float;
	var compassLocs							: array< Vector >;
	
	
	public function Init()
	{
		isGeralt = (thePlayer == GetWitcherPlayer());
		config = GetFHUDConfig();
		hud = (CR4ScriptedHud)theGame.GetHud();
		module = (CR4HudModuleOneliners)(hud.GetHudModule( "OnelinersModule" ));
		marginCenter = hud.GetScaleformPoint( 0.5, 0.5 );
		marginLeftTop = hud.GetScaleformPoint( 0.01, 0.025 );
		marginRightBottom = hud.GetScaleformPoint( 1 - 0.01, 1 - 0.01 );
		theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnMapPinChanged ), new CModMarkersListener in this );
		//cache all markers
		cacheQuestPins = true;
		Cache3DMarkers();
		Cache3DMarkersTracked();
		//init compass marks
		FillCompassLocs();
	}
	
	public function Update( dt : float )
	{
		if( !config )
		{
			Init();
		}
		timeDelta = dt;
		markersAlpha = 100 - config.markersTransparency;
		//theGame.witcherLog.AddMessage( "timeDelta = " + timeDelta );
		if( !theGame.GetGuiManager().IsAnyMenu() )
		{
			if( config.compassMarkersEnabled )
			{
				UpdateCompass();
			}
			else if( bCompassCurrentlyShown )
			{
				CleanupCompassOneliners();
				bCompassCurrentlyShown = false;
			}
			if( config.b3DMarkersEnabled )
			{
				Update3DMarkers();
			}
			else if ( prevOnelinersMaxID > -1 )
			{
				CleanupOneliners();
				bIconCurrentlyShown = false;
				bAltTextCurrentlyShown = false;
				bDescriptionCurrentlyShown = false;
				bDistanceCurrentlyShown = false;
				prevOnelinersMaxID = -1;
			}
		}
	}
	
	public function IsValidID( ID : int ) : bool
	{
		return IsMarkerID( ID ) || IsCompassID( ID );
	}
	
	function IsMarkerID( ID : int ) : bool
	{
		return ( ID >= MARKERS_START_ID && ID <= MARKERS_END_ID );
	}
	
	function IsCompassID( ID : int ) : bool
	{
		return ( ID >= COMPASS_START_ID && ID <= COMPASS_END_ID );
	}
	
	function CleanupOneliners()
	{
		var i : int;
		for( i = MARKERS_START_ID; i < prevOnelinersMaxID; i += 1 )
			module.FXRemoveOneliner( i );
	}
	
	function CleanupCompassOneliners()
	{
		module.FXRemoveOneliner( COMPASS_START_ID );
		module.FXRemoveOneliner( COMPASS_START_ID + 1 );
		module.FXRemoveOneliner( COMPASS_START_ID + 2 );
		module.FXRemoveOneliner( COMPASS_START_ID + 3 );
		module.FXRemoveOneliner( COMPASS_START_ID + 4 );
		module.FXRemoveOneliner( COMPASS_START_ID + 5 );
		module.FXRemoveOneliner( COMPASS_START_ID + 6 );
		module.FXRemoveOneliner( COMPASS_START_ID + 7 );
		module.FXRemoveOneliner( COMPASS_START_ID + 8 );
		module.FXRemoveOneliner( COMPASS_START_ID + 9 );
	}
	
	function ShouldShowIcon() : bool
	{
		if( config.forceShowMarkers || config.markerIconDisplayMode == MDM_Always ||
			config.markerIconDisplayMode == MDM_WS && theGame.GetFocusModeController().IsActive() )
		{
			isIconFadingOut = false;
			return true;
		}
		if( isIconFadingOut && iconFadeOutTime > 0 )
		{
			iconFadeOutTime -= timeDelta;
			return true;
		}
		if( bIconCurrentlyShown && !isIconFadingOut )
		{
			isIconFadingOut = true;
			iconFadeOutTime = config.markersFadeOutDelay;
			return true;
		}
		isIconFadingOut = false;
		return false;
	}
	
	function ShouldShowDescription() : bool
	{
		if( config.forceShowMarkers || config.markerDescriptionDisplayMode == MDM_Always ||
			config.markerDescriptionDisplayMode == MDM_WS && theGame.GetFocusModeController().IsActive() )
		{
			isDescriptionFadingOut = false;
			return true;
		}
		if( isDescriptionFadingOut && descriptionFadeOutTime > 0 )
		{
			descriptionFadeOutTime -= timeDelta;
			return true;
		}
		if( bDescriptionCurrentlyShown && !isDescriptionFadingOut )
		{
			isDescriptionFadingOut = true;
			descriptionFadeOutTime = config.markersFadeOutDelay;
			return true;
		}
		isDescriptionFadingOut = false;
		return false;
	}
	
	function ShouldShowDistance() : bool
	{
		if( config.forceShowMarkers || config.markerDistanceDisplayMode == MDM_Always ||
			config.markerDistanceDisplayMode == MDM_WS && theGame.GetFocusModeController().IsActive() )
		{
			isDistanceFadingOut = false;
			return true;
		}
		if( isDistanceFadingOut && distanceFadeOutTime > 0 )
		{
			distanceFadeOutTime -= timeDelta;
			return true;
		}
		if( bDistanceCurrentlyShown && !isDistanceFadingOut )
		{
			isDistanceFadingOut = true;
			distanceFadeOutTime = config.markersFadeOutDelay;
			return true;
		}
		isDistanceFadingOut = false;
		return false;
	}
	
	function ShouldShowCompass() : bool
	{
		if( config.forceShowMarkers || config.markerCompassDisplayMode == MDM_Always ||
			config.markerCompassDisplayMode == MDM_WS && theGame.GetFocusModeController().IsActive() )
		{
			isCompassFadingOut = false;
			return true;
		}
		if( isCompassFadingOut && compassFadeOutTime > 0 )
		{
			compassFadeOutTime -= timeDelta;
			return true;
		}
		if( bCompassCurrentlyShown && !isCompassFadingOut )
		{
			isCompassFadingOut = true;
			compassFadeOutTime = config.markersFadeOutDelay;
			return true;
		}
		isCompassFadingOut = false;
		return false;
	}
	
	//======================= update compass ==========================
	
	function UpdateCompass()
	{
		var i : int;
		
		if( ShouldShowCompass() )
		{
			for( i = 0; i <= 7; i += 1 )
			{
				UpdateCompassScreenPosition( COMPASS_START_ID + i );
			}
			bCompassCurrentlyShown = true;
		}
		else
		{
			CleanupCompassOneliners();
			bCompassCurrentlyShown = false;
		}
	}
	
	function FillCompassLocs()
	{
		compassLocs.Resize(8);
		compassLocs[0].X -= 100;	compassLocs[0].Y += 100;	// NW
									compassLocs[1].Y += 100;	// N
		compassLocs[2].X += 100;	compassLocs[2].Y += 100;	// NE
		compassLocs[3].X -= 100;								// W
		compassLocs[4].X += 100;								// E
		compassLocs[5].X -= 100;	compassLocs[5].Y -= 100;	// SW
									compassLocs[6].Y -= 100;	// S
		compassLocs[7].X += 100;	compassLocs[7].Y -= 100;	// SE
	}
	
	function GetCompassLoc( ID : int ) : Vector
	{
		return compassLocs[ID - COMPASS_START_ID] + thePlayer.GetWorldPosition();
	}
	
	function GetLocHeading( ID : int ) : float
	{
		return VecHeading( compassLocs[ID - COMPASS_START_ID] );
	}
	
	function UpdateCompassScreenPosition( ID : int )
	{
		var oppositeCamera	: bool;
		var screenPos		: Vector;
		var mcOneliner		: CScriptedFlashSprite;
		var text			: string;
		var camHeading		: float = VecHeading( theCamera.GetCameraDirection() );
		var loc				: Vector;
		
		loc = GetCompassLoc( ID );
		text = GetCompassText( ID );
		oppositeCamera = GetScreenPosOpposite( screenPos, loc );
		screenPos.Y = (marginRightBottom.Y - marginLeftTop.Y) * config.compassScreenPosY;
		//marker is not visible normally
		if( text != "" && ( oppositeCamera || !IsInsideMargins( screenPos ) ) )
		{
			//icons only
			if( ( config.markerIconType == MIT_Icon || config.markerIconType == MIT_Icon_bw ) && AbsF( AngleDistance( camHeading, GetLocHeading( ID ) ) ) < 130 )
			{
				if( screenPos.X <= marginLeftTop.X || oppositeCamera && screenPos.X <= marginCenter.X )
				{
					text = "<img src=\"img://icons/quests/arrow_left.png\" width=\"" + GetArrowSize() + "\" height=\"" + GetIconSize() + "\">" + GetCompassIcon60( ID );
					screenPos.X = marginLeftTop.X + (GetIconSize() + GetArrowSize() )/2;
				}
				else if( screenPos.X >= marginRightBottom.X || oppositeCamera && screenPos.X >= marginCenter.X )
				{
					text = GetCompassIcon60( ID ) + "<img src=\"img://icons/quests/arrow_right.png\" width=\"" + GetArrowSize() + "\" height=\"" + GetIconSize() + "\">";
					screenPos.X = marginRightBottom.X - (GetIconSize() + GetArrowSize() )/2;
				}
				screenPos.Y -= 0.7*GetIconSize()/2;
			}
			else
			{
				text = "";
			}
		}
		mcOneliner = module.FXGetOneliner( ID );
		//if has something to display
		if( text != "" )
		{
			if( !mcOneliner || module.FXGetOnelinerText( ID ).GetTextHtml() != text )
			{
				module.FXRemoveOneliner( ID );
				module.FXCreateOneliner( text, ID );
				mcOneliner = module.FXGetOneliner( ID );
			}
			mcOneliner.SetPosition( screenPos.X, screenPos.Y );
			mcOneliner.SetVisible( true );
			if( isCompassFadingOut )
				mcOneliner.SetAlpha( markersAlpha * MaxF( 0, compassFadeOutTime / config.markersFadeOutDelay ) );
			else
				mcOneliner.SetAlpha( markersAlpha );
		}
		else
		{
			if( mcOneliner )
				mcOneliner.SetVisible( false );
		}
	}
	
	//=========================== update markers ==========================
	
	function Cache3DMarkersIfNeeded()
	{
		var commonMapManager		: CCommonMapManager = theGame.GetCommonMapManager();
		var currentWorldPath		: string = theGame.GetWorld().GetDepotPath();
		var mapPinInstances 		: array< SCommonMapPinInstance >;
		var isGeraltNow				: bool;
	
		isGeraltNow = (thePlayer == GetWitcherPlayer());
		
		//if the player has changed
		if( isGeraltNow != isGeralt )
		{
			//theGame.witcherLog.AddMessage( "Player has changed." );
			Init();
		}
		else if( isDirty && delayedCacheTime - theGame.GetEngineTimeAsSeconds() <= 0 )
		{
			Cache3DMarkers();
		}
		else
		{
			mapPinInstances = commonMapManager.GetMapPinInstances( currentWorldPath );
			//if world path has changed or markers have changed
			if( mapPinInstances.Size() != cachedNumPins || currentWorldPath != cachedWorldPath )
			{
				//theGame.witcherLog.AddMessage( "Map pins changed, caching markers." );
				//if world path has changed, cache everything, if not - only cache map pin entities
				if( currentWorldPath != cachedWorldPath )
					cacheQuestPins = true;
				Cache3DMarkers();
			}
		}
		Cache3DMarkersTracked(); //always re-cache tracked quest markers to properly track moving objectives
	}
	
	function Update3DMarkers()
	{
		Cache3DMarkersIfNeeded();
		
		prevOnelinersMaxID = onelinersMaxID;
		onelinersMaxID = MARKERS_START_ID;
		
		UpdateShownVars();
		InitOnelinersOffsets();
		
		ProcessMarkers( cached3DMarkersStatic  );
		ProcessMarkers( cached3DMarkersDynamic );
		ProcessMarkers( cached3DMarkersTracked );
		ProcessMarkers( SU_fhudPatchAddCustomMarkers(this) );
		
		CleanupUnusedOneliners();
	}
	
	function ProcessMarkers( markers : array< SMod3DMarker > )
	{
		var playerPosition			: Vector = thePlayer.GetWorldPosition();
		var markersCount			: int;
		var i						: int;
		var marker					: SMod3DMarker;
		
		markersCount = markers.Size();
		for( i = 0; i < markersCount; i += 1 )
		{
			marker = markers[i];
			marker.distance = VecDistanceSquared( playerPosition, marker.position );
	
			if( marker.distance < config.markerMinDistanceSquared )
				continue;
			
			//if marker isn't pinned, check for max dist
			if( !marker.pin && marker.distance > config.markerMaxDistanceSquared )
				continue;
			
			//is inside quest zone
			/*if( marker.isHighlighted && marker.distance < mapPin.visibleRadius )
			{
				CleanupCurrentOneliners();
				break;
			}*/
			
			AdjustZLevel( marker );
			UpdateMarker( marker );
		}
	}
	
	function AdjustZLevel( out marker : SMod3DMarker )
	{
		var playerPosition : Vector;
		playerPosition = thePlayer.GetWorldPosition();

		switch( marker.visibleType )
		{
			case 'User1':
			case 'User2':
			case 'User3':
			case 'User4':
				playerPosition = thePlayer.GetWorldPosition();
				marker.position.Z = playerPosition.Z + 0.5;
				return;
			case 'MagicLamp':
			case 'HorseRaceTarget':
			case 'EnemyDead':
			case 'GenericFocus':
				marker.position.Z += 0.5;
				return;
		}
		marker.position.Z += 2.5;
	}
	
	function CleanupCurrentOneliners()
	{
		var i : int;
		for( i = MARKERS_START_ID; i < onelinersMaxID; i += 1 )
			module.FXRemoveOneliner( i );
		bIconCurrentlyShown = false;
		bAltTextCurrentlyShown = false;
		bDescriptionCurrentlyShown = false;
		bDistanceCurrentlyShown = false;
	}
	
	function CleanupUnusedOneliners()
	{
		var i : int;
		for( i = onelinersMaxID; i < prevOnelinersMaxID; i += 1 )
			module.FXRemoveOneliner( i );
	}
	
	function UpdateShownVars()
	{
		if( ShouldShowIcon() )
		{
			bIconCurrentlyShown = true;
			bAltTextCurrentlyShown = ( config.markerIconType == MIT_Text || config.markerIconType == MIT_Text_bw );
		}
		else
		{
			bIconCurrentlyShown = false;
			bAltTextCurrentlyShown = false;
		}
		if( ShouldShowDescription() )
			bDescriptionCurrentlyShown = true;
		else
			bDescriptionCurrentlyShown = false;
		if( ShouldShowDistance() )
			bDistanceCurrentlyShown = true;
		else
			bDistanceCurrentlyShown = false;
	}
	
	function UpdateMarker( out marker : SMod3DMarker )
	{
		var markerText			: string = "";
		var markerDescrText		: string = "";
		var markerDistanceText	: string = "";
		var onelinerTextFlash	: CScriptedFlashTextField;
		var mcOneliner			: CScriptedFlashSprite;
		
		/*markerText = "id: " + pin.id
					+ " tag: " + pin.tag
					+ " customNameId: " + pin.customNameId
					+ " extraTag: " + pin.extraTag
					+ " type: " + pin.type
					+ " visibleType: " + pin.visibleType
					+ " alternateVersion: " + pin.alternateVersion;*/
		//theGame.witcherLog.AddMessage("size = " + GetIconSize());
		
		SetMarkerScreenPosition( marker );
		
		if( bIconCurrentlyShown || marker.force )
		{
			if( marker.onScreen )
				markerText = marker.text;
			else
				markerText = marker.offscreenText;
			marker.onelinerID = onelinersMaxID;
			onelinersMaxID += 1;
			mcOneliner = module.FXGetOneliner( marker.onelinerID );
			if( mcOneliner )
				module.FXRemoveOneliner( marker.onelinerID );
			module.FXCreateOneliner( markerText, marker.onelinerID );
		}
		else
		{
			marker.onelinerID = 0;
		}
		
		if( bDescriptionCurrentlyShown && marker.onScreen )
		{
			markerDescrText = marker.description;
			marker.descrOnelinerID = onelinersMaxID;
			onelinersMaxID += 1;
			mcOneliner = module.FXGetOneliner( marker.descrOnelinerID );
			if( mcOneliner )
				module.FXRemoveOneliner( marker.descrOnelinerID );
			module.FXCreateOneliner( markerDescrText, marker.descrOnelinerID );
		}
		else
		{
			marker.descrOnelinerID = 0;
		}
		
		if( bDistanceCurrentlyShown && marker.onScreen )
		{
			markerDistanceText = GetMarkerDistanceText( marker );
			marker.distOnelinerID = onelinersMaxID;
			onelinersMaxID += 1;
			mcOneliner = module.FXGetOneliner( marker.distOnelinerID );
			if( mcOneliner )
				module.FXRemoveOneliner( marker.distOnelinerID );
			module.FXCreateOneliner( markerDistanceText, marker.distOnelinerID );
		}
		else
		{
			marker.distOnelinerID = 0;
		}
			
		UpdateMarkerOneliner( marker );
	}
	
	function SetMarkerScreenPosition( out marker : SMod3DMarker )
	{
		var shouldProject		: bool;
		var noOppositeCamera	: bool;
		var onScreen			: bool;
		var screenPos			: Vector;
	
		shouldProject = config.compassMarkersEnabled && config.project3DMarkersOnCompass;
		noOppositeCamera = ( shouldProject || config.markerOnScreenOnly );
		onScreen = GetScreenPos( screenPos, marker.position, noOppositeCamera );
		marker.offscreenText = "";
		if( !IsInsideMargins( screenPos ) )
			onScreen = false;
		if( onScreen )
		{
			if( shouldProject )
				screenPos.Y = (marginRightBottom.Y - marginLeftTop.Y) * config.compassScreenPosY + projOffset;
		}
		else if( !noOppositeCamera )
		{
			if( screenPos.X <= marginLeftTop.X )
			{
				if( config.markerIconType == MIT_Icon || config.markerIconType == MIT_Icon_bw )
				{
					marker.offscreenText = "<img src=\"img://icons/quests/arrow_left.png\" width=\"" + GetArrowSize() + "\" height=\"" + GetIconSize() + "\">" + marker.text;
					screenPos.X = marginLeftTop.X + (GetIconSize() + GetArrowSize() )/2;
				}
				else
				{
					marker.offscreenText = "<font size=\"" + config.markersAltTextSize + "\">&lt;</font>" + marker.text;
					screenPos.X = marginLeftTop.X + config.markersAltTextSize;
				}
			}
			else if( screenPos.X >= marginRightBottom.X )
			{
				if( config.markerIconType == MIT_Icon || config.markerIconType == MIT_Icon_bw )
				{
					marker.offscreenText = marker.text + "<img src=\"img://icons/quests/arrow_right.png\" width=\"" + GetArrowSize() + "\" height=\"" + GetIconSize() + "\">";
					screenPos.X = marginRightBottom.X - (GetIconSize() + GetArrowSize() )/2;
				}
				else
				{
					marker.offscreenText = marker.text + "<font size=\"" + config.markersAltTextSize + "\">></font>";
					screenPos.X = marginRightBottom.X - config.markersAltTextSize;
				}
			}
			else if( screenPos.Y <= marginLeftTop.Y )
			{
				if( config.markerIconType == MIT_Icon || config.markerIconType == MIT_Icon_bw )
				{
					marker.offscreenText = "<img src=\"img://icons/quests/arrow_up.png\" width=\"" + GetArrowSize() + "\" height=\"" + GetArrowSize() + "\">" + "<br>" + marker.text;
					screenPos.Y = marginLeftTop.Y + GetIconSize();
				}
				else
				{
					marker.offscreenText = "<font size=\"" + config.markersAltTextSize + "\">^</font><br>" + marker.text;
					screenPos.Y = marginLeftTop.Y + 1.5 * config.markersAltTextSize;
				}
			}
			else
			{
				if( config.markerIconType == MIT_Icon || config.markerIconType == MIT_Icon_bw )
				{
					marker.offscreenText = marker.text + "<br>" + "<img src=\"img://icons/quests/arrow_down.png\" width=\"" + GetArrowSize() + "\" height=\"" + GetArrowSize() + "\">";
					screenPos.Y = marginRightBottom.Y;
				}
				else
				{
					marker.offscreenText = marker.text + "<br><font size=\"" + config.markersAltTextSize + "\">v</font>";
					screenPos.Y = marginRightBottom.Y;
				}
			}
		}
		marker.onScreen = onScreen;
		marker.screenPosition = screenPos;
	}
	
	function UpdateMarkerOneliner( out marker : SMod3DMarker )
	{
		var noOppositeCamera	: bool;
		var mcOneliner			: CScriptedFlashSprite;
		
		noOppositeCamera = ( config.compassMarkersEnabled && config.project3DMarkersOnCompass || config.markerOnScreenOnly );
		if( marker.onelinerID )
		{
			mcOneliner = module.FXGetOneliner( marker.onelinerID );
			if( marker.onScreen || !noOppositeCamera )
			{
				mcOneliner.SetPosition( marker.screenPosition.X, marker.screenPosition.Y );
				mcOneliner.SetVisible( true );
				if( isIconFadingOut && !marker.force )
					mcOneliner.SetAlpha( markersAlpha * MaxF( 0, iconFadeOutTime / config.markersFadeOutDelay ) );
				else
					mcOneliner.SetAlpha( markersAlpha );
			}
			else
				mcOneliner.SetVisible( false );
		}
		if( marker.descrOnelinerID )
		{
			mcOneliner = module.FXGetOneliner( marker.descrOnelinerID );
			if( marker.onScreen )
			{
				mcOneliner.SetPosition( marker.screenPosition.X, marker.screenPosition.Y + descrOffset );
				mcOneliner.SetVisible( true );
				if( isDescriptionFadingOut )
					mcOneliner.SetAlpha( markersAlpha * MaxF( 0, descriptionFadeOutTime / config.markersFadeOutDelay ) );
				else
					mcOneliner.SetAlpha( markersAlpha );
			}
			else
				mcOneliner.SetVisible( false );
		}
		if( marker.distOnelinerID )
		{
			mcOneliner = module.FXGetOneliner( marker.distOnelinerID );
			if( marker.onScreen )
			{
				mcOneliner.SetPosition( marker.screenPosition.X, marker.screenPosition.Y - distOffset );
				mcOneliner.SetVisible( true );
				if( isDistanceFadingOut )
					mcOneliner.SetAlpha( markersAlpha * MaxF( 0, distanceFadeOutTime / config.markersFadeOutDelay ) );
				else
					mcOneliner.SetAlpha( markersAlpha );
			}
			else
				mcOneliner.SetVisible( false );
		}
	}
	
	function IsInsideMargins( screenPos : Vector ) : bool
	{
		if( screenPos.X < marginLeftTop.X || screenPos.X > marginRightBottom.X ||
			screenPos.Y < marginLeftTop.Y || screenPos.Y > marginRightBottom.Y )
			return false;
		else
			return true;
	}

	function GetScreenPos( out screenPos : Vector, worldPos : Vector, optional noOppositeCamera : bool ) : bool
	{
		var camera_rotation: EulerAngles;
		var rotation: EulerAngles;
		var x: float;
		var y: float;
		var pitch: float;

		// we get the normalized X coordinates [0;1] from the angle between the
		// camera heading and the heading toward the pin.
		x = AngleDistance(
			theCamera.GetCameraHeading(),
			VecHeading(worldPos - theCamera.GetCameraPosition())
		) / 90 + 0.5;

		camera_rotation = theCamera.GetCameraRotation();

		rotation = VecToRotation(
			worldPos - theCamera.GetCameraPosition()
		);

		y = AngleDistance(
			camera_rotation.Pitch,
			rotation.Pitch
		) / 75 + 0.5;

		screenPos = hud.GetScaleformPoint( x, y );

		return true;
	}
	
	function GetScreenPosOpposite( out screenPos : Vector, worldPos : Vector ) : bool
	{
		var oppositeCamera : bool = false;
		
		if( !theCamera.WorldVectorToViewRatio( worldPos, screenPos.X, screenPos.Y ) )
		{
			oppositeCamera = true;
			GetOppositeCameraScreenPos( worldPos, screenPos.X, screenPos.Y );
		}
		screenPos.X = ( screenPos.X + 1 ) / 2;
		screenPos.Y = ( screenPos.Y + 1 ) / 2;
		screenPos = hud.GetScaleformPoint( screenPos.X, screenPos.Y );
		return oppositeCamera;
	}
	
	//======================= positioning ======================
	
	function InitOnelinersOffsets()
	{
		projOffset = GetProjOffsetY();
		descrOffset = GetDescrOnelinerOffset();
		distOffset = GetDistanceOnelinerOffset();
	}
	
	function GetProjOffsetY() : float
	{
		var z : float = 0;
		
		if( bAltTextCurrentlyShown )
			z = config.markersAltTextSize;
		else if( bIconCurrentlyShown )
			z = GetIconSize();
		else if( bDistanceCurrentlyShown )
			z = config.markersDistanceTextSize;
		else if( bDescriptionCurrentlyShown )
			z = config.markersDescriptionTextSize;
		if( config.markerIconType == MIT_Icon || config.markerIconType == MIT_Icon_bw )
			z = (z - GetCompassIconSize())/2;
		else
			z = (z - config.markersAltTextSize)/2;
		
		return z;
	}
	
	function GetDescrOnelinerOffset() : float
	{
		var z : float = 0;
		
		z = config.markersDescriptionTextSize;
		if( bIconCurrentlyShown || bDistanceCurrentlyShown )
			z += 5;
		
		return z;
	}
	
	function GetDistanceOnelinerOffset() : float
	{
		var z : float = 0;
		
		if( bAltTextCurrentlyShown )
			z += config.markersAltTextSize + 5;
		else if( bIconCurrentlyShown )
			z += GetIconSize() + 5;
		
		return z;
	}
	
	//========================= font/size ===========================
	
	function GetCompassIconSize() : int
	{
		return 102 * config.markersIconSizePrc / 100;
	}
	
	function GetArrowSize() : int
	{
		return 30 * config.markersIconSizePrc / 100;
	}
	
	function GetIconSize() : int
	{
		return 60 * config.markersIconSizePrc / 100;
	}
	
	function GetDistanceFont() : string
	{
		return " size=\"" + config.markersDistanceTextSize + "\" ";
	}
	
	function GetDescriptionFont() : string
	{
		return " size=\"" + config.markersDescriptionTextSize + "\" ";
	}
	
	function GetCompassFont() : string
	{
		return " face=\"$BoldFont\" color=\"#008000\" size=\"" + config.markersAltTextSize + "\" ";
	}
	
	function GetMarkerDistanceText( marker : SMod3DMarker ) : string
	{
		return "<font" + GetDistanceFont() + ">" + FloatToStringPrec( FloorF( SqrtF( marker.distance ) ), 0 ) + "</font>";
	}
	
	//===================== icon/alt text =========================
	
	function GetCompassText( ID : int ) : string
	{
		switch( config.markerIconType )
		{
			case MIT_Icon:
			case MIT_Icon_bw:
				return GetCompassIcon( ID );
			case MIT_Text:
			case MIT_Text_bw:
				return GetCompassAltText( ID );
		}
		return "";
	}

	function GetCompassIcon( ID : int ) : string
	{
		ID -= COMPASS_START_ID;
		
		switch( ID )
		{
			case 0:
				return "";
			case 1:
				return "<img src=\"img://icons/quests/compass_N.png\" width=\"" + GetCompassIconSize() + "\" height=\"" + GetCompassIconSize() + "\">";
			case 2:
				return "";
			case 3:
				return "<img src=\"img://icons/quests/compass_W.png\" width=\"" + GetCompassIconSize() + "\" height=\"" + GetCompassIconSize() + "\">";
			case 4:
				return "<img src=\"img://icons/quests/compass_E.png\" width=\"" + GetCompassIconSize() + "\" height=\"" + GetCompassIconSize() + "\">";
			case 5:
				return "";
			case 6:
				return "<img src=\"img://icons/quests/compass_S.png\" width=\"" + GetCompassIconSize() + "\" height=\"" + GetCompassIconSize() + "\">";
			case 7:
				return "";
		}
		return "";
	}
	
	function GetCompassIcon60( ID : int ) : string
	{
		ID -= COMPASS_START_ID;
		
		switch( ID )
		{
			case 0:
				return "";
			case 1:
				return "<img src=\"img://icons/quests/compass_N_60.png\" width=\"" + GetIconSize() + "\" height=\"" + GetIconSize() + "\">";
			case 2:
				return "";
			case 3:
				return "<img src=\"img://icons/quests/compass_W_60.png\" width=\"" + GetIconSize() + "\" height=\"" + GetIconSize() + "\">";
			case 4:
				return "<img src=\"img://icons/quests/compass_E_60.png\" width=\"" + GetIconSize() + "\" height=\"" + GetIconSize() + "\">";
			case 5:
				return "";
			case 6:
				return "<img src=\"img://icons/quests/compass_S_60.png\" width=\"" + GetIconSize() + "\" height=\"" + GetIconSize() + "\">";
			case 7:
				return "";
		}
		return "";
	}
	
	function GetCompassAltText( ID : int ) : string
	{
		ID -= COMPASS_START_ID;
		
		switch( ID )
		{
			case 0:
				return "<font" + GetCompassFont() + ">NW</font>";
			case 1:
				return "<font" + GetCompassFont() + ">N</font>";
			case 2:
				return "<font" + GetCompassFont() + ">NE</font>";
			case 3:
				return "<font" + GetCompassFont() + ">W</font>";
			case 4:
				return "<font" + GetCompassFont() + ">E</font>";
			case 5:
				return "<font" + GetCompassFont() + ">SW</font>";
			case 6:
				return "<font" + GetCompassFont() + ">S</font>";
			case 7:
				return "<font" + GetCompassFont() + ">SE</font>";
		}
		return "";
	}

	function GetMarkerIconByType( marker : SMod3DMarker ) : string
	{
		switch( config.markerIconType )
		{
			case MIT_Icon:
				return GetMarkerIcon( marker );
			case MIT_Icon_bw:
				return GetMarkerIconBW( marker );
			case MIT_Text:
				return GetMarkerAltText( marker );
			case MIT_Text_bw:
				return GetMarkerAltTextBW( marker );
			default:
				return "";
		}
	}
	
	function GetQuestIconByLevel( marker : SMod3DMarker ) : string
	{
		switch( marker.lvlDiff )
		{
			case QL_NORMAL:
				return "\"img://icons/quests/quest_tracked_green.png\"";
			case QL_HIGH:
				return "\"img://icons/quests/quest_tracked_red.png\"";
			case QL_LOW:
				return "\"img://icons/quests/quest_tracked_gray.png\"";
		}
		return "\"img://icons/quests/quest_tracked_white.png\"";
	}
	
	function GetMarkerIcon( marker : SMod3DMarker ) : string
	{
		var iconPath : string;
	
		if( marker.isActiveQuest )
		{
			if( marker.isHighlighted )
				iconPath = "<img src=\"img://icons/quests/quest_tracked_orange.png\"";
			else
				iconPath = "<img src=\"img://icons/quests/quest_tracked_orange_sub.png\"";
		}
		else
		{
			switch( marker.visibleType )
			{
				//quests
				case 'QuestReturn':
					iconPath = "<img src=\"img://icons/quests/quest_question_yellow.png\"";
					break;
				case 'MonsterQuest':
					iconPath = "<img src=\"img://icons/quests/quest_monsterhunt.png\"";
					break;
				case 'TreasureQuest':
					iconPath = "<img src=\"img://icons/quests/quest_treasure.png\"";
					break;
				case 'StoryQuest':
				case 'ChapterQuest':
				case 'SideQuest':
					iconPath = "<img src=" + GetQuestIconByLevel( marker );
					break;
				case 'QuestAvailable':
					iconPath = "<img src=\"img://icons/quests/quest_exclamation_yellow.png\"";
					break;
				case 'QuestAvailableHoS':
					iconPath = "<img src=\"img://icons/quests/quest_exclamation_blue.png\"";
					break;
				case 'QuestAvailableBaW':
				case 'QuestBelgard':
				case 'QuestCoronata':
				case 'QuestVermentino':
					iconPath = "<img src=\"img://icons/quests/quest_exclamation_orange.png\"";
					break;
				case 'HorseRace':
				case 'BoatRace':
					iconPath = "<img src=\"img://icons/quests/quest_horse_race.png\"";
					break;
				//utility signs
				case 'User1':
					iconPath = "<img src=\"img://icons/quests/user1.png\"";
					break;
				case 'User2':
					iconPath = "<img src=\"img://icons/quests/user2.png\"";
					break;
				case 'User3':
					iconPath = "<img src=\"img://icons/quests/user3.png\"";
					break;
				case 'User4':
					iconPath = "<img src=\"img://icons/quests/user4.png\"";
					break;
				case 'Horse':
					iconPath = "<img src=\"img://icons/quests/roach.png\"";
					break;
				case 'Boat':
					iconPath = "<img src=\"img://icons/quests/boat.png\"";
					break;
				case 'RoadSign':
					iconPath = "<img src=\"img://icons/quests/road_sign.png\"";
					break;
				case 'Harbor':
					iconPath = "<img src=\"img://icons/quests/harbor.png\"";
					break;
				case 'Entrance':
					iconPath = "<img src=\"img://icons/quests/cave_entrance.png\"";
					break;
				case 'NoticeBoard':
					iconPath = "<img src=\"img://icons/quests/noticeboard_white.png\"";
					break;
				case 'NoticeBoardFull':
					iconPath = "<img src=\"img://icons/quests/noticeboard_quest.png\"";
					break;
				case 'Whetstone':
					iconPath = "<img src=\"img://icons/quests/whetstone.png\"";
					break;
				case 'ArmorRepairTable':
					iconPath = "<img src=\"img://icons/quests/armor_repair_table.png\"";
					break;
				case 'WitcherHouse':
					iconPath = "<img src=\"img://icons/quests/witcher_house.png\"";
					break;
				case 'AlchemyTable':
					iconPath = "<img src=\"img://icons/quests/alchemy_table.png\"";
					break;
				case 'MutagenDismantle':
					iconPath = "<img src=\"img://icons/quests/mutagen_dismantle.png\"";
					break;
				case 'Stables':
					iconPath = "<img src=\"img://icons/quests/stables.png\"";
					break;
				case 'Bookshelf':
					iconPath = "<img src=\"img://icons/quests/bookshelf.png\"";
					break;
				case 'Bed':
					iconPath = "<img src=\"img://icons/quests/bed.png\"";
					break;
				case 'PlayerStash':
				case 'PlayerStashDiscoverable':
					iconPath = "<img src=\"img://icons/quests/player_stash.png\"";
					break;
				//NPCs
				case 'Cammerlengo':
					iconPath = "<img src=\"img://icons/quests/cammerlengo.png\"";
					break;
				case 'DyeMerchant':
					iconPath = "<img src=\"img://icons/quests/dye_merchant.png\"";
					break;
				case 'WineMerchant':
					iconPath = "<img src=\"img://icons/quests/wine_merchant.png\"";
					break;
				case 'Shopkeeper':
					iconPath = "<img src=\"img://icons/quests/shopkeeper.png\"";
					break;
				case 'Blacksmith':
					iconPath = "<img src=\"img://icons/quests/blacksmith.png\"";
					break;
				case 'Armorer':
					iconPath = "<img src=\"img://icons/quests/armorer.png\"";
					break;
				case 'Archmaster':
					iconPath = "<img src=\"img://icons/quests/archmaster.png\"";
					break;
				case 'Hairdresser':
					iconPath = "<img src=\"img://icons/quests/hairdresser.png\"";
					break;
				case 'Alchemic':
					iconPath = "<img src=\"img://icons/quests/alchemist.png\"";
					break;
				case 'Herbalist':
					iconPath = "<img src=\"img://icons/quests/herbalist.png\"";
					break;
				case 'Innkeeper':
					iconPath = "<img src=\"img://icons/quests/innkeeper.png\"";
					break;
				case 'Enchanter':
					iconPath = "<img src=\"img://icons/quests/enchanter.png\"";
					break;
				case 'Torch':
					iconPath = "<img src=\"img://icons/quests/torch.png\"";
					break;
				case 'Prostitute':
					iconPath = "<img src=\"img://icons/quests/prostitute.png\"";
					break;
				//POIs
				case 'NotDiscoveredPOI':
					iconPath = "<img src=\"img://icons/quests/quest_question_white.png\"";
					break;
				case 'MonsterNest':
					iconPath = "<img src=\"img://icons/quests/monster_nest.png\"";
					break;
				case 'MonsterNestDisabled':
					iconPath = "<img src=\"img://icons/quests/monster_nest_disabled.png\"";
					break;
				case 'InfestedVineyard':
					iconPath = "<img src=\"img://icons/quests/infested_vineyard.png\"";
					break;
				case 'InfestedVineyardDisabled':
					iconPath = "<img src=\"img://icons/quests/infested_vineyard_disabled.png\"";
					break;
				case 'PlaceOfPower':
					iconPath = "<img src=\"img://icons/quests/place_of_power.png\"";
					break;
				case 'PlaceOfPowerDisabled':
					iconPath = "<img src=\"img://icons/quests/place_of_power_disabled.png\"";
					break;
				case 'TreasureHuntMappin':
					iconPath = "<img src=\"img://icons/quests/quest_treasure.png\"";
					break;
				case 'TreasureHuntMappinDisabled':
					iconPath = "<img src=\"img://icons/quests/quest_treasure_disabled.png\"";
					break;
				case 'SpoilsOfWar':
					iconPath = "<img src=\"img://icons/quests/spoils_of_war.png\"";
					break;
				case 'SpoilsOfWarDisabled':
					iconPath = "<img src=\"img://icons/quests/spoils_of_war_disabled.png\"";
					break;
				case 'BanditCamp':
					iconPath = "<img src=\"img://icons/quests/person_in_distress.png\"";
					break;
				case 'BanditCampDisabled':
					iconPath = "<img src=\"img://icons/quests/person_in_distress_disabled.png\"";
					break;
				case 'BanditCampfire':
					iconPath = "<img src=\"img://icons/quests/bandit_camp.png\"";
					break;
				case 'BanditCampfireDisabled':
					iconPath = "<img src=\"img://icons/quests/bandit_camp_disabled.png\"";
					break;
				case 'BossAndTreasure':
					iconPath = "<img src=\"img://icons/quests/guarded_treasure.png\"";
					break;
				case 'BossAndTreasureDisabled':
					iconPath = "<img src=\"img://icons/quests/guarded_treasure_disabled.png\"";
					break;
				case 'Contraband':
				case 'ContrabandShip':
					iconPath = "<img src=\"img://icons/quests/contraband.png\"";
					break;
				case 'ContrabandDisabled':
				case 'ContrabandShipDisabled':
					iconPath = "<img src=\"img://icons/quests/contraband_disabled.png\"";
					break;
				case 'RescuingTown':
					iconPath = "<img src=\"img://icons/quests/rescuing_town.png\"";
					break;
				case 'RescuingTownDisabled':
					iconPath = "<img src=\"img://icons/quests/rescuing_town_disabled.png\"";
					break;
				case 'DungeonCrawl':
					iconPath = "<img src=\"img://icons/quests/dungeon_crawl.png\"";
					break;
				case 'DungeonCrawlDisabled':
					iconPath = "<img src=\"img://icons/quests/dungeon_crawl_disabled.png\"";
					break;
				case 'Hideout':
					iconPath = "<img src=\"img://icons/quests/hansa_hideout.png\"";
					break;
				case 'HideoutDisabled':
					iconPath = "<img src=\"img://icons/quests/hansa_hideout_disabled.png\"";
					break;
				case 'Plegmund':
					iconPath = "<img src=\"img://icons/quests/lebjoda_statue.png\"";
					break;
				case 'PlegmundDisabled':
					iconPath = "<img src=\"img://icons/quests/lebjoda_statue_disabled.png\"";
					break;
				case 'KnightErrant':
					iconPath = "<img src=\"img://icons/quests/knight_errand.png\"";
					break;
				case 'KnightErrantDisabled':
					iconPath = "<img src=\"img://icons/quests/knight_errand_disabled.png\"";
					break;
				case 'WineContract':
					iconPath = "<img src=\"img://icons/quests/wine_contract.png\"";
					break;
				case 'WineContractDisabled':
					iconPath = "<img src=\"img://icons/quests/wine_contract_disabled.png\"";
					break;
				case 'SignalingStake':
					iconPath = "<img src=\"img://icons/quests/bandit_campfire.png\"";
					break;
				case 'SignalingStakeDisabled':
					iconPath = "<img src=\"img://icons/quests/bandit_campfire_disabled.png\"";
					break;
				//misc
				case 'Rift':
				case 'Teleport':
					iconPath = "<img src=\"img://icons/quests/teleport.png\"";
					break;
				case 'MagicLamp':
					iconPath = "<img src=\"img://icons/quests/magic_lamp.png\"";
					break;
				case 'HorseRaceTarget':
					iconPath = "<img src=\"img://icons/quests/horse_race_target.png\"";
					break;
				case 'HorseRaceDummy':
					iconPath = "<img src=\"img://icons/quests/horse_race_dummy.png\"";
					break;
				case 'Herb':
					iconPath = "<img src=\"img://icons/quests/herb.png\"";
					break;
				case 'Enemy':
					iconPath = "<img src=\"img://icons/quests/enemy.png\"";
					break;
				case 'EnemyDead':
					iconPath = "<img src=\"img://icons/quests/dead_body.png\"";
					break;
				case 'GenericFocus':
					iconPath = "<img src=\"img://icons/quests/ws_clue.png\"";
					break;
				default:
					iconPath = "<img src=\"img://icons/quests/quest_question_white.png\"";
					break;
			}
		}
		iconPath += " width=\"" + GetIconSize() + "\" height=\"" + GetIconSize() + "\">";
		return iconPath;
	}

	function GetMarkerIconBW( marker : SMod3DMarker ) : string
	{
		var iconPath : string;
	
		if( marker.isActiveQuest )
		{
			//if( marker.isHighlighted )
				iconPath = "<img src=\"img://icons/quests/quest_tracked_white.png\"";
			//else
			//	iconPath = "<img src=\"img://icons/quests/quest_tracked_white.png\"";
		}
		else
		{
			switch( marker.visibleType )
			{
				//quests
				case 'QuestReturn':
					iconPath = "<img src=\"img://icons/quests/quest_tracked_white.png\"";
					break;
				case 'MonsterQuest':
					iconPath = "<img src=\"img://icons/quests/quest_monsterhunt_white.png\"";
					break;
				case 'TreasureQuest':
					iconPath = "<img src=\"img://icons/quests/quest_treasure_white.png\"";
					break;
				case 'StoryQuest':
				case 'ChapterQuest':
				case 'SideQuest':
					iconPath = "<img src=\"img://icons/quests/quest_tracked_gray.png\"";
					break;
				case 'QuestAvailable':
				case 'QuestAvailableHoS':
				case 'QuestAvailableBaW':
				case 'QuestBelgard':
				case 'QuestCoronata':
				case 'QuestVermentino':
					iconPath = "<img src=\"img://icons/quests/quest_exclamation_white.png\"";
					break;
				case 'HorseRace':
				case 'BoatRace':
					iconPath = "<img src=\"img://icons/quests/quest_horse_race_white.png\"";
					break;
				//utility signs
				case 'User1':
					iconPath = "<img src=\"img://icons/quests/user1_white.png\"";
					break;
				case 'User2':
					iconPath = "<img src=\"img://icons/quests/user2_white.png\"";
					break;
				case 'User3':
					iconPath = "<img src=\"img://icons/quests/user3_white.png\"";
					break;
				case 'User4':
					iconPath = "<img src=\"img://icons/quests/user4_white.png\"";
					break;
				case 'Horse':
					iconPath = "<img src=\"img://icons/quests/roach_white.png\"";
					break;
				case 'Boat':
					iconPath = "<img src=\"img://icons/quests/boat_white.png\"";
					break;
				case 'RoadSign':
					iconPath = "<img src=\"img://icons/quests/road_sign_white.png\"";
					break;
				case 'Harbor':
					iconPath = "<img src=\"img://icons/quests/harbor_white.png\"";
					break;
				case 'Entrance':
					iconPath = "<img src=\"img://icons/quests/cave_entrance_white.png\"";
					break;
				case 'NoticeBoard':
					iconPath = "<img src=\"img://icons/quests/noticeboard_white.png\"";
					break;
				case 'NoticeBoardFull':
					iconPath = "<img src=\"img://icons/quests/noticeboard_quest_white.png\"";
					break;
				case 'Whetstone':
					iconPath = "<img src=\"img://icons/quests/whetstone_white.png\"";
					break;
				case 'ArmorRepairTable':
					iconPath = "<img src=\"img://icons/quests/armor_repair_table_white.png\"";
					break;
				case 'WitcherHouse':
					iconPath = "<img src=\"img://icons/quests/witcher_house_white.png\"";
					break;
				case 'AlchemyTable':
					iconPath = "<img src=\"img://icons/quests/alchemy_table_white.png\"";
					break;
				case 'MutagenDismantle':
					iconPath = "<img src=\"img://icons/quests/mutagen_dismantle_white.png\"";
					break;
				case 'Stables':
					iconPath = "<img src=\"img://icons/quests/stables_white.png\"";
					break;
				case 'Bookshelf':
					iconPath = "<img src=\"img://icons/quests/bookshelf_white.png\"";
					break;
				case 'Bed':
					iconPath = "<img src=\"img://icons/quests/bed_white.png\"";
					break;
				case 'PlayerStash':
				case 'PlayerStashDiscoverable':
					iconPath = "<img src=\"img://icons/quests/player_stash_white.png\"";
					break;
				//NPCs
				case 'Cammerlengo':
					iconPath = "<img src=\"img://icons/quests/cammerlengo_white.png\"";
					break;
				case 'DyeMerchant':
					iconPath = "<img src=\"img://icons/quests/dye_merchant_white.png\"";
					break;
				case 'WineMerchant':
					iconPath = "<img src=\"img://icons/quests/wine_merchant_white.png\"";
					break;
				case 'Shopkeeper':
					iconPath = "<img src=\"img://icons/quests/shopkeeper_white.png\"";
					break;
				case 'Blacksmith':
					iconPath = "<img src=\"img://icons/quests/blacksmith_white.png\"";
					break;
				case 'Armorer':
					iconPath = "<img src=\"img://icons/quests/armorer_white.png\"";
					break;
				case 'Archmaster':
					iconPath = "<img src=\"img://icons/quests/archmaster_white.png\"";
					break;
				case 'Hairdresser':
					iconPath = "<img src=\"img://icons/quests/hairdresser_white.png\"";
					break;
				case 'Alchemic':
					iconPath = "<img src=\"img://icons/quests/alchemist_white.png\"";
					break;
				case 'Herbalist':
					iconPath = "<img src=\"img://icons/quests/herbalist_white.png\"";
					break;
				case 'Innkeeper':
					iconPath = "<img src=\"img://icons/quests/innkeeper_white.png\"";
					break;
				case 'Enchanter':
					iconPath = "<img src=\"img://icons/quests/enchanter_white.png\"";
					break;
				case 'Torch':
					iconPath = "<img src=\"img://icons/quests/torch_white.png\"";
					break;
				case 'Prostitute':
					iconPath = "<img src=\"img://icons/quests/prostitute_white.png\"";
					break;
				//POIs
				case 'NotDiscoveredPOI':
					iconPath = "<img src=\"img://icons/quests/quest_question_white.png\"";
					break;
				case 'MonsterNest':
					iconPath = "<img src=\"img://icons/quests/monster_nest_white.png\"";
					break;
				case 'MonsterNestDisabled':
					iconPath = "<img src=\"img://icons/quests/monster_nest_disabled.png\"";
					break;
				case 'InfestedVineyard':
					iconPath = "<img src=\"img://icons/quests/infested_vineyard_white.png\"";
					break;
				case 'InfestedVineyardDisabled':
					iconPath = "<img src=\"img://icons/quests/infested_vineyard_disabled.png\"";
					break;
				case 'PlaceOfPower':
					iconPath = "<img src=\"img://icons/quests/place_of_power_white.png\"";
					break;
				case 'PlaceOfPowerDisabled':
					iconPath = "<img src=\"img://icons/quests/place_of_power_disabled.png\"";
					break;
				case 'TreasureHuntMappin':
					iconPath = "<img src=\"img://icons/quests/quest_treasure_white.png\"";
					break;
				case 'TreasureHuntMappinDisabled':
					iconPath = "<img src=\"img://icons/quests/quest_treasure_disabled.png\"";
					break;
				case 'SpoilsOfWar':
					iconPath = "<img src=\"img://icons/quests/spoils_of_war_white.png\"";
					break;
				case 'SpoilsOfWarDisabled':
					iconPath = "<img src=\"img://icons/quests/spoils_of_war_disabled.png\"";
					break;
				case 'BanditCamp':
					iconPath = "<img src=\"img://icons/quests/person_in_distress_white.png\"";
					break;
				case 'BanditCampDisabled':
					iconPath = "<img src=\"img://icons/quests/person_in_distress_disabled.png\"";
					break;
				case 'BanditCampfire':
					iconPath = "<img src=\"img://icons/quests/bandit_camp_white.png\"";
					break;
				case 'BanditCampfireDisabled':
					iconPath = "<img src=\"img://icons/quests/bandit_camp_disabled.png\"";
					break;
				case 'BossAndTreasure':
					iconPath = "<img src=\"img://icons/quests/guarded_treasure_white.png\"";
					break;
				case 'BossAndTreasureDisabled':
					iconPath = "<img src=\"img://icons/quests/guarded_treasure_disabled.png\"";
					break;
				case 'Contraband':
				case 'ContrabandShip':
					iconPath = "<img src=\"img://icons/quests/contraband_white.png\"";
					break;
				case 'ContrabandDisabled':
				case 'ContrabandShipDisabled':
					iconPath = "<img src=\"img://icons/quests/contraband_disabled.png\"";
					break;
				case 'RescuingTown':
					iconPath = "<img src=\"img://icons/quests/rescuing_town_white.png\"";
					break;
				case 'RescuingTownDisabled':
					iconPath = "<img src=\"img://icons/quests/rescuing_town_disabled.png\"";
					break;
				case 'DungeonCrawl':
					iconPath = "<img src=\"img://icons/quests/dungeon_crawl_white.png\"";
					break;
				case 'DungeonCrawlDisabled':
					iconPath = "<img src=\"img://icons/quests/dungeon_crawl_disabled.png\"";
					break;
				case 'Hideout':
					iconPath = "<img src=\"img://icons/quests/hansa_hideout_white.png\"";
					break;
				case 'HideoutDisabled':
					iconPath = "<img src=\"img://icons/quests/hansa_hideout_disabled.png\"";
					break;
				case 'Plegmund':
					iconPath = "<img src=\"img://icons/quests/lebjoda_statue_white.png\"";
					break;
				case 'PlegmundDisabled':
					iconPath = "<img src=\"img://icons/quests/lebjoda_statue_disabled.png\"";
					break;
				case 'KnightErrant':
					iconPath = "<img src=\"img://icons/quests/knight_errand_white.png\"";
					break;
				case 'KnightErrantDisabled':
					iconPath = "<img src=\"img://icons/quests/knight_errand_disabled.png\"";
					break;
				case 'WineContract':
					iconPath = "<img src=\"img://icons/quests/wine_contract_white.png\"";
					break;
				case 'WineContractDisabled':
					iconPath = "<img src=\"img://icons/quests/wine_contract_disabled.png\"";
					break;
				case 'SignalingStake':
					iconPath = "<img src=\"img://icons/quests/bandit_campfire_white.png\"";
					break;
				case 'SignalingStakeDisabled':
					iconPath = "<img src=\"img://icons/quests/bandit_campfire_disabled.png\"";
					break;
				//misc
				case 'Rift':
				case 'Teleport':
					iconPath = "<img src=\"img://icons/quests/teleport_white.png\"";
					break;
				case 'MagicLamp':
					iconPath = "<img src=\"img://icons/quests/magic_lamp_white.png\"";
					break;
				case 'HorseRaceTarget':
					iconPath = "<img src=\"img://icons/quests/horse_race_target_white.png\"";
					break;
				case 'HorseRaceDummy':
					iconPath = "<img src=\"img://icons/quests/horse_race_dummy_white.png\"";
					break;
				case 'Herb':
					iconPath = "<img src=\"img://icons/quests/herb_white.png\"";
					break;
				case 'Enemy':
					iconPath = "<img src=\"img://icons/quests/enemy_white.png\"";
					break;
				case 'EnemyDead':
					iconPath = "<img src=\"img://icons/quests/dead_body_white.png\"";
					break;
				case 'GenericFocus':
					iconPath = "<img src=\"img://icons/quests/ws_clue_white.png\"";
					break;
				default:
					iconPath = "<img src=\"img://icons/quests/quest_question_white.png\"";
					break;
			}
		}
		iconPath += " width=\"" + GetIconSize() + "\" height=\"" + GetIconSize() + "\">";
		return iconPath;
	}
	
	function GetQuestAltTextByLevel( marker : SMod3DMarker ) : string
	{
		switch( marker.lvlDiff )
		{
			case QL_NORMAL:
				return " color=\"#89d889\">*";
			case QL_HIGH:
				return " color=\"#ff6655\">*";
			case QL_LOW:
				return " color=\"#cccccc\">*";
		}
		return " >*";
	}
	
	function GetMarkerAltText( marker : SMod3DMarker ) : string
	{
		var altText : string;
	
		if( marker.isActiveQuest )
		{
			if( marker.isHighlighted )
				altText = " face=\"$BoldFont\" color=\"#ff9900\">*";
			else
				altText = " color=\"#ff9900\">*";
		}
		else
		{
			switch( marker.visibleType )
			{
				//quests
				case 'QuestReturn':
					altText = " face=\"$BoldFont\" color=\"#ff9900\">?";
					break;
				case 'MonsterQuest':
				case 'TreasureQuest':
				case 'StoryQuest':
				case 'ChapterQuest':
				case 'SideQuest':
					altText = GetQuestAltTextByLevel( marker );
					break;
				case 'QuestAvailable':
					altText = " color=\"#ffcc00\">!";
					break;
				case 'QuestAvailableHoS':
					altText = " color=\"#55aae3\">!";
					break;
				case 'QuestAvailableBaW':
				case 'QuestBelgard':
				case 'QuestCoronata':
				case 'QuestVermentino':
					altText = " color=\"#fb712f\">!";
					break;
				case 'HorseRace':
				case 'BoatRace':
					altText = " color=\"#cd853f\">!";
					break;
				//utility signs
				case 'User1':
					altText = " color=\"#06b952\">x";
					break;
				case 'User2':
					altText = " color=\"#ff6655\">x";
					break;
				case 'User3':
					altText = " color=\"#67a9f8\">x";
					break;
				case 'User4':
					altText = " color=\"#fb712f\">x";
					break;
				case 'Horse':
				case 'Boat':
				case 'RoadSign':
				case 'Harbor':
				case 'Entrance':
				case 'Whetstone':
				case 'ArmorRepairTable':
				case 'WitcherHouse':
				case 'PlayerStash':
				case 'PlayerStashDiscoverable':
				case 'AlchemyTable':
				case 'MutagenDismantle':
				case 'Stables':
				case 'Bookshelf':
				case 'Bed':
					altText = " color=\"#89d889\">@";
					break;
				case 'NoticeBoard':
					altText = " >!";
					break;
				case 'NoticeBoardFull':
					altText = " color=\"#ffcc00\">!";
					break;
				//NPCs
				case 'Cammerlengo':
				case 'DyeMerchant':
				case 'WineMerchant':
				case 'Shopkeeper':
				case 'Blacksmith':
				case 'Armorer':
				case 'Archmaster':
				case 'Innkeeper':
				case 'Enchanter':
					altText = " color=\"#fff68f\">$";
					break;
				case 'Hairdresser':
					altText = " color=\"#67a9f8\">$";
					break;
				case 'Alchemic':
				case 'Herbalist':
					altText = " color=\"#8ebd2f\">$";
					break;
				case 'Prostitute':
					altText = " color=\"#991a1a\">$";
					break;
				case 'Torch':
					altText = " color=\"#ff6655\">+";
					break;
				//POIs
				case 'NotDiscoveredPOI':
					altText = " >?";
					break;
				case 'MonsterNest':
				case 'InfestedVineyard':
				case 'PlaceOfPower':
				case 'TreasureHuntMappin':
				case 'SpoilsOfWar':
				case 'BanditCamp':
				case 'BanditCampfire':
				case 'BossAndTreasure':
				case 'Contraband':
				case 'ContrabandShip':
				case 'RescuingTown':
				case 'DungeonCrawl':
				case 'Hideout':
				case 'Plegmund':
				case 'KnightErrant':
				case 'WineContract':
				case 'SignalingStake':
					altText = " >o";
					break;
				case 'MonsterNestDisabled':
				case 'InfestedVineyardDisabled':
				case 'PlaceOfPowerDisabled':
				case 'TreasureHuntMappinDisabled':
				case 'SpoilsOfWarDisabled':
				case 'BanditCampDisabled':
				case 'BanditCampfireDisabled':
				case 'BossAndTreasureDisabled':
				case 'ContrabandDisabled':
				case 'ContrabandShipDisabled':
				case 'RescuingTownDisabled':
				case 'DungeonCrawlDisabled':
				case 'HideoutDisabled':
				case 'PlegmundDisabled':
				case 'KnightErrantDisabled':
				case 'WineContractDisabled':
				case 'SignalingStakeDisabled':
					altText = " color=\"#999999\">o";
					break;
				//misc
				case 'Rift':
				case 'Teleport':
					altText = " color=\"#cc66ff\">#";
					break;
				case 'MagicLamp':
					altText = " color=\"#00ee33\">#";
					break;
				case 'HorseRaceTarget':
					altText = " color=\"#cc66ff\">x";
					break;
				case 'HorseRaceDummy':
					altText = " color=\"#cc66ff\">x";
					break;
				case 'Herb':
					altText = " color=\"#8ebd2f\">#";
					break;
				case 'Enemy':
					altText = " color=\"#ff6655\">+";
					break;
				case 'EnemyDead':
					altText = " color=\"#ff6655\">x";
					break;
				case 'GenericFocus':
					altText = " color=\"#ff6655\">#";
					break;
				default:
					altText = " >?";
					break;
			}
		}
		altText = "<font size=\"" + config.markersAltTextSize + "\" " + altText + "</font>";
		return altText;
	}

	function GetMarkerAltTextBW( marker : SMod3DMarker ) : string
	{
		var altText : string;
	
		if( marker.isActiveQuest )
		{
			if( marker.isHighlighted )
				altText = " face=\"$BoldFont\">*";
			else
				altText = " >*";
		}
		else
		{
			switch( marker.visibleType )
			{
				//quests
				case 'QuestReturn':
					altText = " face=\"$BoldFont\">?";
					break;
				case 'MonsterQuest':
				case 'TreasureQuest':
				case 'StoryQuest':
				case 'ChapterQuest':
				case 'SideQuest':
					altText = " >*";
					break;
				case 'QuestAvailable':
				case 'QuestAvailableHoS':
				case 'QuestAvailableBaW':
				case 'QuestBelgard':
				case 'QuestCoronata':
				case 'QuestVermentino':
				case 'HorseRace':
				case 'BoatRace':
					altText = " >!";
					break;
				//utility signs
				case 'User1':
				case 'User2':
				case 'User3':
				case 'User4':
					altText = " >x";
					break;
				case 'Horse':
				case 'Boat':
				case 'RoadSign':
				case 'Harbor':
				case 'Entrance':
				case 'Whetstone':
				case 'ArmorRepairTable':
				case 'WitcherHouse':
				case 'PlayerStash':
				case 'PlayerStashDiscoverable':
				case 'AlchemyTable':
				case 'MutagenDismantle':
				case 'Stables':
				case 'Bookshelf':
				case 'Bed':
					altText = " >@";
					break;
				case 'NoticeBoard':
				case 'NoticeBoardFull':
					altText = " >!";
					break;
				//NPCs
				case 'Cammerlengo':
				case 'DyeMerchant':
				case 'WineMerchant':
				case 'Shopkeeper':
				case 'Blacksmith':
				case 'Armorer':
				case 'Archmaster':
				case 'Innkeeper':
				case 'Enchanter':
				case 'Hairdresser':
				case 'Alchemic':
				case 'Herbalist':
				case 'Prostitute':
					altText = " >$";
					break;
				case 'Torch':
					altText = " >+";
					break;
				//POIs
				case 'NotDiscoveredPOI':
					altText = " >?";
					break;
				case 'MonsterNest':
				case 'InfestedVineyard':
				case 'PlaceOfPower':
				case 'TreasureHuntMappin':
				case 'SpoilsOfWar':
				case 'BanditCamp':
				case 'BanditCampfire':
				case 'BossAndTreasure':
				case 'Contraband':
				case 'ContrabandShip':
				case 'RescuingTown':
				case 'DungeonCrawl':
				case 'Hideout':
				case 'Plegmund':
				case 'KnightErrant':
				case 'WineContract':
				case 'SignalingStake':
				case 'MonsterNestDisabled':
				case 'InfestedVineyardDisabled':
				case 'PlaceOfPowerDisabled':
				case 'TreasureHuntMappinDisabled':
				case 'SpoilsOfWarDisabled':
				case 'BanditCampDisabled':
				case 'BanditCampfireDisabled':
				case 'BossAndTreasureDisabled':
				case 'ContrabandDisabled':
				case 'ContrabandShipDisabled':
				case 'RescuingTownDisabled':
				case 'DungeonCrawlDisabled':
				case 'HideoutDisabled':
				case 'PlegmundDisabled':
				case 'KnightErrantDisabled':
				case 'WineContractDisabled':
				case 'SignalingStakeDisabled':
					altText = " >o";
					break;
				//misc
				case 'Rift':
				case 'Teleport':
				case 'MagicLamp':
				case 'Herb':
				case 'GenericFocus':
					altText = " >#";
					break;
				case 'HorseRaceTarget':
				case 'HorseRaceDummy':
				case 'EnemyDead':
					altText = " >x";
					break;
				case 'Enemy':
					altText = " >+";
					break;
				default:
					altText = " >?";
					break;
			}
		}
		altText = "<font size=\"" + config.markersAltTextSize + "\" " + altText + "</font>";
		return altText;
	}
	
	//================= on/off conditions ========================
	
	function ShouldShowMarker( marker : SMod3DMarker ) : bool
	{
		if( marker.pin || marker.force )
			return true;
		if( IsActiveQuest( marker ) )
			return config.markersShowQuests == MV_Show;
		if( IsQuest( marker ) )
			return config.markersShowQuestsAll == MV_Show;
		if( IsUserMain( marker ) )
			return config.markersShowUser == MV_Show;
		if( IsUserAdditional( marker ) )
			return config.markersShowUserAll == MV_Show;
		if( IsMapLocation( marker ) )
			return config.markersShowMapLoc == MV_Show;
		if( IsNPC( marker ) )
			return config.markersShowNPCs == MV_Show;
		if( IsPOIUndiscovered( marker ) )
			return config.markersShowUndiscovered == MV_Show;
		if( IsPOI( marker ) )
			return config.markersShowPOIs == MV_Show;
		if( IsPOIDisabled( marker ) )
			return config.markersShowDisabled == MV_Show;
		if( IsMisc( marker ) )
			return config.markersShowMisc == MV_Show;
		if( IsHerb( marker ) )
			return config.markersShowHerbs == MV_Show;
		if( IsEnemy( marker ) )
			return config.markersShowEnemies == MV_Show;
		if( IsEnemyDead( marker ) )
			return config.markersShowDeadEnemies == MV_Show;
		if( IsWSClue( marker ) )
			return config.markersShowWSClues == MV_Show;
		/*if( pin.type == 'NPC' ||
				pin.type == 'PointOfInterestMappin' )
			continue;*/
		//theGame.witcherLog.AddMessage( "marker: " + marker.visibleType );
		return false;
	}
	
	function ShouldPinMarker( marker : SMod3DMarker ) : bool
	{
		if( IsActiveQuest( marker ) )
			return config.markersShowQuests == MV_Pin;
		if( IsQuest( marker ) )
			return config.markersShowQuestsAll == MV_Pin;
		if( IsUserMain( marker ) )
			return config.markersShowUser == MV_Pin;
		if( IsUserAdditional( marker ) )
			return config.markersShowUserAll == MV_Pin;
		if( IsMapLocation( marker ) )
			return config.markersShowMapLoc == MV_Pin;
		if( IsNPC( marker ) )
			return config.markersShowNPCs == MV_Pin;
		if( IsPOIUndiscovered( marker ) )
			return config.markersShowUndiscovered == MV_Pin;
		if( IsPOI( marker ) )
			return config.markersShowPOIs == MV_Pin;
		if( IsPOIDisabled( marker ) )
			return config.markersShowDisabled == MV_Pin;
		if( IsMisc( marker ) )
			return config.markersShowMisc == MV_Pin;
		if( IsHerb( marker ) )
			return config.markersShowHerbs == MV_Pin;
		if( IsEnemy( marker ) )
			return config.markersShowEnemies == MV_Pin;
		if( IsEnemyDead( marker ) )
			return config.markersShowDeadEnemies == MV_Pin;
		if( IsWSClue( marker ) )
			return config.markersShowWSClues == MV_Pin;
		return false;
	}
	
	function ShouldForceMarker( marker : SMod3DMarker ) : bool
	{
		if( IsActiveQuest( marker ) )
			return config.markersShowQuests == MV_Force;
		if( IsQuest( marker ) )
			return config.markersShowQuestsAll == MV_Force;
		if( IsUserMain( marker ) )
			return config.markersShowUser == MV_Force;
		if( IsUserAdditional( marker ) )
			return config.markersShowUserAll == MV_Force;
		if( IsMapLocation( marker ) )
			return config.markersShowMapLoc == MV_Force;
		if( IsNPC( marker ) )
			return config.markersShowNPCs == MV_Force;
		if( IsPOIUndiscovered( marker ) )
			return config.markersShowUndiscovered == MV_Force;
		if( IsPOI( marker ) )
			return config.markersShowPOIs == MV_Force;
		if( IsPOIDisabled( marker ) )
			return config.markersShowDisabled == MV_Force;
		if( IsMisc( marker ) )
			return config.markersShowMisc == MV_Force;
		if( IsHerb( marker ) )
			return config.markersShowHerbs == MV_Force;
		if( IsEnemy( marker ) )
			return config.markersShowEnemies == MV_Force;
		if( IsEnemyDead( marker ) )
			return config.markersShowDeadEnemies == MV_Force;
		if( IsWSClue( marker ) )
			return config.markersShowWSClues == MV_Force;
		return false;
	}
	
	function IsActiveQuest( marker : SMod3DMarker ) : bool
	{
		return marker.isActiveQuest;
	}
	
	function IsQuest( marker : SMod3DMarker ) : bool
	{
		switch( marker.visibleType )
		{
			case 'StoryQuest':
			case 'ChapterQuest':
			case 'SideQuest':
			case 'QuestReturn':
			case 'MonsterQuest':
			case 'TreasureQuest':
			case 'QuestAvailable':
			case 'QuestAvailableHoS':
			case 'QuestAvailableBaW':
			case 'QuestBelgard':
			case 'QuestCoronata':
			case 'QuestVermentino':
			case 'HorseRace':
			case 'BoatRace':
				return true;
		}
		return false;
	}
	
	function IsUserMain( marker : SMod3DMarker ) : bool
	{
		return ( marker.visibleType == 'User1' );
	}
	
	function IsUserAdditional( marker : SMod3DMarker ) : bool
	{
		switch( marker.visibleType )
		{
			case 'User2':
			case 'User3':
			case 'User4':
				return true;
		}
		return false;
	}
	
	function IsRoadSign( marker : SMod3DMarker ) : bool
	{
		return ( marker.visibleType == 'RoadSign' );
	}
	
	function IsMapLocation( marker : SMod3DMarker ) : bool
	{
		switch( marker.visibleType )
		{
			case 'Horse':
			case 'Boat':
			case 'RoadSign':
			case 'Harbor':
			case 'Entrance':
			case 'NoticeBoard':
			case 'NoticeBoardFull':
			case 'Whetstone':
			case 'ArmorRepairTable':
			case 'PlayerStash':
			case 'PlayerStashDiscoverable':
			case 'WitcherHouse':
			case 'AlchemyTable':
			case 'MutagenDismantle':
			case 'Stables':
			case 'Bookshelf':
			case 'Bed':
				return true;
		}
		return false;
	}
	
	function IsNPC( marker : SMod3DMarker ) : bool
	{
		switch( marker.visibleType )
		{
			case 'Cammerlengo':
			case 'DyeMerchant':
			case 'WineMerchant':
			case 'Shopkeeper':
			case 'Blacksmith':
			case 'Armorer':
			case 'Archmaster':
			case 'Hairdresser':
			case 'Alchemic':
			case 'Herbalist':
			case 'Innkeeper':
			case 'Enchanter':
			case 'Torch':
			case 'Prostitute':
				return true;
		}
		return false;
	}
	
	function IsPOIUndiscovered( marker : SMod3DMarker ) : bool
	{
		return ( marker.visibleType == 'NotDiscoveredPOI' );
	}
	
	function IsPOI( marker : SMod3DMarker ) : bool
	{
		switch( marker.visibleType )
		{
			case 'MonsterNest':
			case 'InfestedVineyard':
			case 'PlaceOfPower':
			case 'TreasureHuntMappin':
			case 'SpoilsOfWar':
			case 'BanditCamp':
			case 'BanditCampfire':
			case 'BossAndTreasure':
			case 'Contraband':
			case 'ContrabandShip':
			case 'RescuingTown':
			case 'DungeonCrawl':
			case 'Hideout':
			case 'Plegmund':
			case 'KnightErrant':
			case 'WineContract':
			case 'SignalingStake':
				return true;
		}
		return false;
	}
	
	function IsPOIDisabled( marker : SMod3DMarker ) : bool
	{
		switch( marker.visibleType )
		{
			case 'MonsterNestDisabled':
			case 'InfestedVineyardDisabled':
			case 'PlaceOfPowerDisabled':
			case 'TreasureHuntMappinDisabled':
			case 'SpoilsOfWarDisabled':
			case 'BanditCampDisabled':
			case 'BanditCampfireDisabled':
			case 'BossAndTreasureDisabled':
			case 'ContrabandDisabled':
			case 'ContrabandShipDisabled':
			case 'RescuingTownDisabled':
			case 'DungeonCrawlDisabled':
			case 'HideoutDisabled':
			case 'PlegmundDisabled':
			case 'KnightErrantDisabled':
			case 'WineContractDisabled':
			case 'SignalingStakeDisabled':
				return true;
		}
		return false;
	}
	
	function IsHerb( marker : SMod3DMarker ) : bool
	{
		return ( marker.visibleType == 'Herb' );
	}
	
	function IsEnemy( marker : SMod3DMarker ) : bool
	{
		return ( marker.visibleType == 'Enemy' );
	}
	
	function IsEnemyDead( marker : SMod3DMarker ) : bool
	{
		return ( marker.visibleType == 'EnemyDead' );
	}
	
	function IsWSClue( marker : SMod3DMarker ) : bool
	{
		return ( marker.visibleType == 'GenericFocus' );
	}
	
	function IsMisc( marker : SMod3DMarker ) : bool
	{
		switch( marker.visibleType )
		{
			case 'Rift':
			case 'Teleport':
			case 'MagicLamp':
			case 'HorseRaceTarget':
			case 'HorseRaceDummy':
				return true;
		}
		return false;
	}
	
	function IsDynamic( marker : SMod3DMarker ) : bool
	{
		return IsNPC( marker ) || IsHerb( marker ) || IsEnemy( marker ) ||
				IsEnemyDead( marker ) || IsWSClue( marker ) || IsMisc( marker );
	}
	
	//========================== cache markers =================================
	
	public function SignalCache3DMarkers( questPins : bool )
	{
		if( !isDirty )
		{
			isDirty = true;
			delayedCacheTime = theGame.GetEngineTimeAsSeconds() + 0.5f;
		}
		cacheQuestPins = questPins;
	}
	
	private function CacheQuestMapPins()
	{
		var mapManager				: CCommonMapManager = theGame.GetCommonMapManager();
		var currentWorldPath		: string = theGame.GetWorld().GetDepotPath();
		var journalManager			: CWitcherJournalManager = theGame.GetJournalManager();
		var trackedQuest			: CJournalQuest;
		var highlightedObjective	: CJournalQuestObjective;
		var activeQuests			: array<CJournalBase>;
		var currentQuest			: CJournalQuest;
		var currentPhase			: CJournalQuestPhase;
		var currentObjective		: CJournalQuestObjective;
		var mapPinInstances			: array< SCommonMapPinInstance >;
		var pin						: SCommonMapPinInstance;
		var i, j, k, m				: int;
		var lvlDiff					: EQuestLevel;
		
		//theGame.witcherLog.AddMessage( "CacheQuestMapPins" );
		
		FactsAdd( "quest_map_pins_hack_disable_sound" );
		
		journalManager.GetActivatedOfType( 'CJournalQuest', activeQuests );
		trackedQuest = journalManager.GetTrackedQuest();
		highlightedObjective = journalManager.GetHighlightedObjective();
		
		cachedQuestPins.Clear();
		cachedQuestLevels.Clear();
		
		for( i = 0; i < activeQuests.Size(); i += 1 )
		{
			currentQuest = (CJournalQuest)activeQuests[i];
			if( currentQuest == trackedQuest )
				continue;
			if( currentQuest && journalManager.GetEntryStatus( currentQuest ) == JS_Active && ( !config.markerHideActivities || !IsActivity( currentQuest ) ) )
			{
				journalManager.SetTrackedQuest( currentQuest );
				lvlDiff = GetLevelDiff( currentQuest );
				for( j = 0; j < currentQuest.GetNumChildren(); j += 1 )
				{
					currentPhase = (CJournalQuestPhase)currentQuest.GetChild(j);
					if( currentPhase && journalManager.GetEntryStatus( currentPhase ) == JS_Active )
					{
						for( k = 0; k < currentPhase.GetNumChildren(); k += 1 )
						{
							currentObjective = (CJournalQuestObjective)currentPhase.GetChild(k);
							if( currentObjective && journalManager.GetEntryStatus( currentObjective ) == JS_Active )
							{
								journalManager.SetHighlightedObjective( currentObjective );
								//theGame.witcherLog.AddMessage( currentObjective.GetUniqueScriptTag() );
								if( NormalizeArea( currentObjective.GetWorld() ) == NormalizeArea( mapManager.GetAreaFromWorldPath( currentWorldPath ) ) )
								{
									mapPinInstances = mapManager.GetMapPinInstances( currentWorldPath );
									//theGame.witcherLog.AddMessage( mapPinInstances.Size() );
									for( m = 0; m < mapPinInstances.Size(); m += 1 )
									{
										pin = mapPinInstances[m];
										if( !pin.isDisabled && pin.guid == currentObjective.guid && ( pin.isDiscovered || pin.isKnown ) )
										{
											pin.isHighlighted = false;
											cachedQuestPins.PushBack( pin );
											cachedQuestLevels.PushBack( lvlDiff );
											//theGame.witcherLog.AddMessage( GetMarkerDescription( pin ) );
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		journalManager.SetTrackedQuest( trackedQuest );
		journalManager.SetHighlightedObjective( highlightedObjective );
		
		FactsRemove( "quest_map_pins_hack_disable_sound" );
	}
	
	private function NormalizeArea( area : EAreaName ) : EAreaName
	{
		if( area == AN_Velen )
			area = AN_NMLandNovigrad;
		
		return area;
	}
	
	private function GetLevelDiff( targetQuest : CJournalQuest ) : EQuestLevel
	{
		var i, j	: int;
		var levels	: C2dArray;
		var qName	: string;
		var qLevel	: int;
		var lvlDiff	: int;

		for( i = 0; i < theGame.questLevelsContainer.Size(); i += 1 )
		{
			levels = theGame.questLevelsContainer[i];
			for( j = 0; j < levels.GetNumRows(); j += 1 )
			{
				qName = levels.GetValueAtAsName(0, j);
				if( qName == targetQuest.baseName )
				{
					qLevel = NameToInt( levels.GetValueAtAsName(1, j) );
					if( qLevel > 1 )
					{
						if( FactsQuerySum( "NewGamePlus" ) > 0 )
							qLevel += theGame.params.GetNewGamePlusLevel();
						lvlDiff = qLevel - thePlayer.GetLevel();
						if( lvlDiff <= -theGame.params.LEVEL_DIFF_HIGH )
							return QL_LOW;
						if( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )
							return QL_HIGH;
					}
					return QL_NORMAL;
				}
			}
		}

		return QL_NORMAL;
	}
	
	private function IsActivity( targetQuest : CJournalQuest ) : bool
	{
		switch( NameToString(targetQuest.GetUniqueScriptTag()) )
		{
			case "NML: Fist Fighting BD0558AA-4C809220-048AB2BB-453FC15D":
			case "NVG: Fist Fighting ADB63834-4EFADC15-0B036E9D-D61D4EDD":
			case "SKG: Fist Fight Championship 3B9CD0F0-4CE07724-3F8C88BA-4B34E232":
			case "NML Horse Race: Baron's Men 6E696C48-49E62FEA-947FC48E-AB746137":
			case "MQ3026 Novigrad Horse Racing B3338F99-4362DADA-4BA1F9AD-95F10F44":
			case "SKG Horse Race: Championship 020A073B-472AEE70-ABE51B81-90B67F37":
			case "SKG Horse Race: Ferlund E6D3273C-48408AE2-334D1792-9E1250AA":
			case "SKG Horse Race: Fejrlesdal 459A8157-4727C1B3-9C3A718F-C271FC41":
			case "SKG Horse Race: Hindarsfjall A9CAEC8F-4FB88A21-24A21A94-3F615E3C":
			case "Card Game Meta: Gather All 22A27919-4ECCF7E1-9F536F90-D140CB21":
			case "CG : No Man's Land BECB3BA0-4C293A48-C3C229B6-31A1439A":
			case "CG: Innkeepers 15BA81D3-4E85B6BD-DF83E995-5D7770CE":
			case "CG: Novigrad 40B54F3B-48857011-9EC0B3BC-5A7537E2":
			case "CG: Skellige 72BA3A67-4CFD722A-0A378284-F4E41BC2":
			case "cammerlengo AFAD298F-47B94308-D6D65092-02F3FC2E":
			case "cg700_all_cards 10792209-4257AE39-5B821199-2FFB20EC":
			case "cg700_tournament DBBF356D-4FFC9CC0-29404AAF-D6208B48":
			case "sq701_tournament":
			case "ff701_fistfights AF499A50-4016055D-97A4A787-06336148":
			case "ff701_master D3B2B89D-4E35CBA8-70F0B39C-46F2BF82":
				return true;
		}
		return false;
	}
	
	//=============================================================================
	
	function InitUserMarker( out userMarker : SMod3DMarker ) : bool
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		var area, numPins, id, type, i : int;
		var pinX, pinY : float;
		
		numPins = mapManager.GetUserMapPinCount();
		for( i = 0; i < numPins; i += 1 )
		{
			mapManager.GetUserMapPinByIndex( i, id, area, pinX, pinY, type );
			if( area == mapManager.GetCurrentArea() && type == 0 )
			{
				userMarker.visibleType = 'User1';
				userMarker.position.X = pinX;
				userMarker.position.Y = pinY;
				return true;
			}
		}
		return false;
	}
	
	function Cache3DMarkers()
	{
		var commonMapManager		: CCommonMapManager = theGame.GetCommonMapManager();
		var currentWorldPath		: string = theGame.GetWorld().GetDepotPath();
		var mapPinInstances 		: array< SCommonMapPinInstance >;
		var mapPinInstancesCount	: int;
		var i						: int;
		var mapPin					: SCommonMapPinInstance;
		var marker					: SMod3DMarker;
		var questsStartingIdx		: int = 0;
		//var mStatic, mDynamic		: array< SMod3DMarker >;
		var userMarker				: SMod3DMarker;
		var hasUserMarker, userMarkerSubstituted : bool;
		var disabledPins			: array< string > = theGame.GetCommonMapManager().GetDisabledMapPins();
		var journalManager			: CWitcherJournalManager = theGame.GetJournalManager();
		var highlightedObjective	: CJournalQuestObjective;
		
		/*theGame.witcherLog.AddMessage( "Disabled Pins:" );
		for( i = 0; i < disabledPins.Size(); i += 1 )
		{
			theGame.witcherLog.AddMessage( disabledPins[i] );
		}*/
		
		cached3DMarkersStatic.Clear();
		cached3DMarkersDynamic.Clear();
		
		//cache all quest map pins (all but tracked quest)
		if( cacheQuestPins )
			CacheQuestMapPins();
		
		//get map pins (all but non-tracked quests)
		mapPinInstances = commonMapManager.GetMapPinInstances( currentWorldPath );
		
		cachedWorldPath = currentWorldPath;
		cachedNumPins = mapPinInstances.Size();
		questsStartingIdx = cachedNumPins;
		
		//append cached map pins for non-tracked quests
		for( i = 0; i < cachedQuestPins.Size(); i += 1 )
			mapPinInstances.PushBack( cachedQuestPins[i] );
		
		mapPinInstancesCount = mapPinInstances.Size();
		
		hasUserMarker = InitUserMarker( userMarker );
		userMarkerSubstituted = false;
		
		highlightedObjective = journalManager.GetHighlightedObjective();
		
		for( i = 0; i < mapPinInstancesCount; i += 1 )
		{
			mapPin = mapPinInstances[i];
			//skip highlighted objective markers (updated separately)
			if( highlightedObjective && mapPin.guid == highlightedObjective.guid )
				continue;
			marker.visibleType = mapPin.visibleType;
			marker.isDiscovered = mapPin.isDiscovered;
			marker.isKnown = mapPin.isKnown;
			marker.isDisabled = mapPin.isDisabled;
			marker.position = mapPin.position;
			ResetQuestMarkerStatus( marker );
			//skip disabled markers
			if( config.markersSyncWithMap && disabledPins.Contains( mapPin.visibleType ) )
				continue;
			//skip unknown markers
			if( !marker.isDiscovered && !marker.isKnown )
			{
				if( !IsRoadSign( marker ) || !config.markerShowUndiscoveredRoadsigns )
					continue;
			}
			//always skip disabled quest map pins
			if( marker.isDisabled && IsQuest( marker ) )
				continue;
			//other disabled pins use menu setting
			if( marker.isDisabled && !config.markersShowDisabled )
				continue;
			if( i >= questsStartingIdx )
				marker.lvlDiff = cachedQuestLevels[i - questsStartingIdx];
			else if( commonMapManager.IsQuestPinType( mapPin.type ) )
				SetQuestMarkerStatus( marker, mapPin );
			marker.force = ShouldForceMarker( marker );
			marker.pin = ShouldPinMarker( marker );
			if( hasUserMarker && config.markerPinWithUserMarker )
			{
				if( IsUserMain( marker ) )
				{
					marker.description = GetMarkerDescription( mapPin );
					marker.text = GetMarkerIconByType( marker );
					userMarker = marker;
					continue;
				}
				//user pinned markers ignore both visibility and max distance settings
				else if( !userMarkerSubstituted && VecDistanceSquared2D( marker.position, userMarker.position ) <= 16.f )
				{
					userMarkerSubstituted = true;
					marker.force = true;
					marker.pin = true;
				}
			}
			//cached3DMarkers.PushBack( marker );
			//Dynamic markers like herbs and especially WS clues lead to rearranging
			//of array elements and redrawing of oneliners - i.e. they cause flickering
			//when enabled. Without proper map/dictionary proper caching is PITA and
			//this is just a hacky workaround, but oh well.
			if( ShouldShowMarker( marker ) )
			{
				marker.description = GetMarkerDescription( mapPin );
				marker.text = GetMarkerIconByType( marker );
				if( IsDynamic( marker ) )
					cached3DMarkersDynamic.PushBack( marker );
				else
					cached3DMarkersStatic.PushBack( marker );
			}
			//theGame.witcherLog.AddMessage( "MAPPIN " + mapPin.id + ": " + mapPin.tag + " : " + mapPin.visibleType );
		}
		
		//for( i = 0; i < mStatic.Size(); i += 1 )
		//	cached3DMarkers.PushBack( mStatic[i] );
		//for( i = 0; i < mDynamic.Size(); i += 1 )
		//	cached3DMarkers.PushBack( mDynamic[i] );
		
		if( !userMarkerSubstituted && ShouldShowMarker( userMarker ) )
		{
			cached3DMarkersStatic.PushBack( userMarker );
		}
		
		isDirty = false;
		cacheQuestPins = false;
	}
	
	function Cache3DMarkersTracked()
	{
		var commonMapManager		: CCommonMapManager = theGame.GetCommonMapManager();
		var currentWorldPath		: string = theGame.GetWorld().GetDepotPath();
		var mapPinInstances 		: array< SCommonMapPinInstance >;
		var mapPinInstancesCount	: int;
		var i						: int;
		var mapPin					: SCommonMapPinInstance;
		var marker					: SMod3DMarker;
		var userMarker				: SMod3DMarker;
		var hasUserMarker, userMarkerSubstituted : bool;
		var disabledPins			: array< string > = theGame.GetCommonMapManager().GetDisabledMapPins();
		var journalManager			: CWitcherJournalManager = theGame.GetJournalManager();
		var highlightedObjective	: CJournalQuestObjective;
		
		cached3DMarkersTracked.Clear();
		
		mapPinInstances = commonMapManager.GetMapPinInstances( currentWorldPath );
		mapPinInstancesCount = mapPinInstances.Size();
		
		hasUserMarker = InitUserMarker( userMarker );
		userMarkerSubstituted = false;
		
		highlightedObjective = journalManager.GetHighlightedObjective();

		if( !highlightedObjective )
			return;
		
		for( i = 0; i < mapPinInstancesCount; i += 1 )
		{
			mapPin = mapPinInstances[i];
			//skip all, but tracked objective markers
			if(mapPin.guid != highlightedObjective.guid)
				continue;
			marker.visibleType = mapPin.visibleType;
			marker.isDiscovered = mapPin.isDiscovered;
			marker.isKnown = mapPin.isKnown;
			marker.isDisabled = mapPin.isDisabled;
			marker.position = mapPin.position;
			marker.isHighlighted = true;
			marker.isActiveQuest = true;
			//skip disabled markers
			if( config.markersSyncWithMap && disabledPins.Contains( mapPin.visibleType ) )
				continue;
			//skip unknown markers
			if( !marker.isDiscovered && !marker.isKnown )
			{
				if( !IsRoadSign( marker ) || !config.markerShowUndiscoveredRoadsigns )
					continue;
			}
			//always skip disabled quest map pins
			if( marker.isDisabled )
				continue;
			marker.force = ShouldForceMarker( marker );
			marker.pin = ShouldPinMarker( marker );
			if( hasUserMarker && config.markerPinWithUserMarker )
			{
				if( !userMarkerSubstituted && VecDistanceSquared2D( marker.position, userMarker.position ) <= 16.f )
				{
					userMarkerSubstituted = true;
					marker.force = true;
					marker.pin = true;
				}
			}
			if( ShouldShowMarker( marker ) )
			{
				marker.description = GetMarkerDescription( mapPin );
				marker.text = GetMarkerIconByType( marker );
				cached3DMarkersTracked.PushBack( marker );
			}
		}
	}
	
	function ResetQuestMarkerStatus( out marker : SMod3DMarker )
	{
		marker.isHighlighted = false;
		marker.isActiveQuest = false;
	}
	
	function SetQuestMarkerStatus( out marker : SMod3DMarker, pin : SCommonMapPinInstance )
	{
		var journalManager			: CWitcherJournalManager = theGame.GetJournalManager();
		var curObjective			: CJournalQuestObjective;
		var highlightedObjective	: CJournalQuestObjective;
		var curQuest				: CJournalQuest;
		var highlightedQuest		: CJournalQuest;
		
		highlightedObjective = journalManager.GetHighlightedObjective();
		curObjective = (CJournalQuestObjective)journalManager.GetEntryByGuid( pin.guid );
		if( curObjective && curObjective == highlightedObjective )
			marker.isHighlighted = true;
		else
			marker.isHighlighted = false;
		highlightedQuest = journalManager.GetHighlightedQuest();
		if( curObjective )
			curQuest = curObjective.GetParentQuest();
		if( curQuest && curQuest == highlightedQuest )
			marker.isActiveQuest = true;
		else
			marker.isActiveQuest = false;
	}
	
	function GetMarkerDescription( targetPin: SCommonMapPinInstance ) : string
	{
		var definitionManager	: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var journalManager		: CWitcherJournalManager = theGame.GetJournalManager();
		var curObjective		: CJournalQuestObjective;
		var curQuest			: CJournalQuest;
		var label				: string;
		
		switch( targetPin.visibleType )
		{
			case 'StoryQuest':
			case 'ChapterQuest':
			case 'SideQuest':
			case 'MonsterQuest':
			case 'TreasureQuest':
			case 'QuestReturn':
			case 'HorseRace':
			case 'BoatRace':
			case 'QuestBelgard':
			case 'QuestCoronata':
			case 'QuestVermentino':
				curObjective = (CJournalQuestObjective)journalManager.GetEntryByGuid( targetPin.guid );
				if( curObjective )
				{
					curQuest = curObjective.GetParentQuest();
					label = GetLocStringById( curQuest.GetTitleStringId() );
				}
				break;
			case 'Horse':
			case 'Rift':
			case 'Teleport':
			case 'QuestAvailable':
			case 'QuestAvailableHoS':
			case 'QuestAvailableBaW':
			case 'MagicLamp':
			case 'HorseRaceTarget':
			case 'HorseRaceDummy':
			case 'Whetstone':
			case 'Entrance':
			case 'NotDiscoveredPOI':
				label = GetLocStringByKeyExt( StrLower( "map_location_" + targetPin.visibleType ) );
				break;
			case 'MonsterNest':
			case 'MonsterNestDisabled':
			case 'InfestedVineyard':
			case 'InfestedVineyardDisabled':
			case 'PlaceOfPower':
			case 'PlaceOfPowerDisabled':
			case 'TreasureHuntMappin':
			case 'TreasureHuntMappinDisabled':
			case 'SpoilsOfWar':
			case 'SpoilsOfWarDisabled':
			case 'BanditCamp':
			case 'BanditCampDisabled':
			case 'BanditCampfire':
			case 'BanditCampfireDisabled':
			case 'BossAndTreasure':
			case 'BossAndTreasureDisabled':
			case 'Contraband':
			case 'ContrabandDisabled':
			case 'ContrabandShip':
			case 'ContrabandShipDisabled':
			case 'RescuingTown':
			case 'RescuingTownDisabled':
			case 'DungeonCrawl':
			case 'DungeonCrawlDisabled':
			case 'Hideout':
			case 'HideoutDisabled':
			case 'Plegmund':
			case 'PlegmundDisabled':
			case 'KnightErrant':
			case 'KnightErrantDisabled':
			case 'WineContract':
			case 'WineContractDisabled':
			case 'SignalingStake':
			case 'SignalingStakeDisabled':
			case 'AlchemyTable':
			case 'WitcherHouse':
			case 'MutagenDismantle':
			case 'Stables':
			case 'Bookshelf':
			case 'Bed':
				label = GetLocStringByKeyExt( StrLower( "map_location_" + targetPin.type ) );
				break;
			case 'PlayerStash':
			case 'PlayerStashDiscoverable':
				label = GetLocStringByKeyExt( "map_location_playerstash" );
				break;
			case 'Cammerlengo':
			case 'DyeMerchant':
			case 'WineMerchant':
			case 'Shopkeeper':
			case 'Blacksmith':
			case 'Armorer':
			case 'Archmaster':
			case 'Hairdresser':
				label = GetLocStringByKeyExt( StrLower( "map_location_" + targetPin.type ) );
				break;
			case 'Alchemic':
				label = GetLocStringByKeyExt( StrLower( "map_location_alchemic" ) );
				break;
			case 'Herbalist':
				label = GetLocStringByKeyExt( StrLower( "herbalist" ) );
				break;
			case 'Innkeeper':
				label = GetLocStringById( 175619 );
				break;
			case 'Enchanter':
				label = GetLocStringByKeyExt( "panel_map_enchanter_pin_name" );
				break;
			case 'Torch':
				label = GetLocStringByKeyExt( "map_location_torch" );
				break;
			case 'Prostitute':
				label = GetLocStringByKeyExt( "novigrad_courtisan" );
				break;
			case 'ArmorRepairTable':
				label = GetLocStringByKeyExt( "map_location_armor_repair_table" );
				break;
			case 'Herb': 
				label= GetLocStringByKeyExt( definitionManager.GetItemLocalisationKeyName( targetPin.tag ) );
				break;
			case 'RoadSign':
				label = GetLocStringByKeyExt( StrLower( "map_location_" + targetPin.tag ) );
				break;
			case 'NoticeBoard':
			case 'NoticeBoardFull':
				label = GetLocStringByKeyExt( StrLower( "map_location_noticeboard" ) );
				break;
			case 'Boat':
				label = GetLocStringByKeyExt( StrLower( "panel_hud_boat" ) );
				break;
			case 'User1':
			case 'User2':
			case 'User3':
			case 'User4':
				label = GetLocStringByKeyExt( StrLower( "map_location_user" ) );
				break;
			default:
				if ( targetPin.customNameId != 0 )
					label = GetLocStringById( targetPin.customNameId );
				else
					label = GetLocStringByKeyExt( StrLower( "map_location_" + targetPin.visibleType ) );
				break;
		}
		label = "<font" + GetDescriptionFont() + ">" + label + "</font>";
		return label;
	}
}

function Mod3DMarkersSignalCache3DMarkers( questPins : bool )
{
	//theGame.witcherLog.AddMessage( "Mod3DMarkersSignalCache3DMarkers" );
	((CR4HudModuleOneliners)((CR4ScriptedHud)theGame.GetHud()).GetHudModule( "OnelinersModule" )).SignalCache3DMarkers( questPins );
}
//---=== modFriendlyHUD ===---