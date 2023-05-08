function SUOL_getManager(): SUOL_Manager {
	var manager: SUOL_Manager;
	var storage: SU_Storage;

  SUOL_Logger("SUOL_getManager()");
	
	storage = SU_getStorage();
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

function SUOL_findOnelinersWithTag(tag: string): array<SU_Oneliner> {
	var manager: SUOL_Manager;

	manager.findByPredicate((new SUOL_PredicateTag in manager).init(tag));
}

function SUOL_findOnelinersWithTagPrefix(suffix: string): array<SU_Oneliner> {
	var manager: SUOL_Manager;

	manager.findByPredicate((new SUOL_PredicateTagStartsWith in manager).init(suffix));
}
