function SUOL_getManager(): SUOL_Manager {
  SUOL_Logger("SUOL_getManager()");
	return thePlayer.getSharedutilsOnelinersManager();
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
