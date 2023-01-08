function SUTB_getManager(): SU_TinyBootstrapperManager {
	var manager: SU_TinyBootstrapperManager;
	var storage: SU_Storage;
	
	storage = SU_getStorage();
	manager = (SU_TinyBootstrapperManager)storage.getItem("SU_TinyBootstrapperManager");

	if (!manager) {
		manager = new SU_TinyBootstrapperManager in storage;

		storage.setItem(manager);
	}

	return manager;
}

function SU_tinyBootstrapperInit(player_input: CPlayerInput)
{
	SUTB_getManager().init();
}

function SU_tinyBootstrapperStop(player_input: CPlayerInput) 
{
	SUTB_getManager().stopMods();
}

function SUTB_getModByTag(tag: name): SU_BaseBootstrappedMod
{
	return SUTB_getManager().getModByTag(tag);
}

function SUTB_Logger(message: string, informGUI: bool)
{
	LogChannel('SUTB', message);
	
	if (informGUI) 
	{
		theGame.GetGuiManager()
			.ShowNotification("SUTB: " + message, 5, true);
	}
}