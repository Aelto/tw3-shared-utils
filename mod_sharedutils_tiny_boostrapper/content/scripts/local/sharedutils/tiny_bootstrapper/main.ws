//---------------------------------------------------
//-- Function: Initialise Bootstrapper --------------
//---------------------------------------------------

function SU_tinyBootstrapperInit(player_input: CPlayerInput)
{
	if (!player_input.SU_tiny_bootstrapper_manager) 
	{
		player_input.SU_tiny_bootstrapper_manager = new SU_TinyBootstrapperManager in player_input;
	}
	player_input.SU_tiny_bootstrapper_manager.init();
}

//---------------------------------------------------
//-- Function: Stop Mods (Shutdown) -----------------
//---------------------------------------------------

function SU_tinyBootstrapperStop(player_input: CPlayerInput) 
{
	player_input.SU_tiny_bootstrapper_manager.stopMods();
}

//---------------------------------------------------
//-- Function: Get Mod By Tag -----------------------
//---------------------------------------------------

function SUTB_getModByTag(tag: name): SU_BaseBootstrappedMod
{
	return thePlayer.GetInputHandler().SU_tiny_bootstrapper_manager.getModByTag(tag);
}

//---------------------------------------------------
//-- Function: Logger -------------------------------
//---------------------------------------------------

function SU_Logger(message: string, informGUI: bool)
{
	LogChannel('SU Bootstrapper', message);
	
	if (informGUI) 
	{
		theGame.GetGuiManager().ShowNotification("SU Bootstrapper" + message, 5, true);
	}
}

//---------------------------------------------------
//-- End Of Code ------------------------------------
//---------------------------------------------------