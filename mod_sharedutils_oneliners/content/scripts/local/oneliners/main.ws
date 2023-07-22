function SUOL_getManager(): SUOL_Manager {
	var manager: SUOL_Manager;
	var storage: SU_Storage;

  SUOL_Logger("SUOL_getManager()");
	
	storage = SU_getBuffer();
	manager = (SUOL_Manager)storage.getItem("SUOL_Manager");

	if (!manager) {
    SUOL_Logger("SUOL_getManager(), received null, instantiating instance");

		manager = new SUOL_Manager in storage;

		storage.setItem(manager);
	}

	return manager;
}

function SUOL_Logger(message: string, optional informGUI: bool) {
	LogChannel('SUOL', message);
	
	if (informGUI) {
		theGame.GetGuiManager().ShowNotification("SUOL: " + message, 5, true);
	}
}

exec function SUOL_deleteByTagPrefix(prefix: string) {
	var output: array<SU_Oneliner>;

	output = SUOL_getManager().deleteByTagPrefix(prefix);
	SUOL_Logger("removed " + output.Size() + " oneliners");
}
