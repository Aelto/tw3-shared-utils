
function SU_getStorage(): SU_Storage {
	var player_input: CPlayerInput;

	player_input = thePlayer.GetInputHandler();

	if (!player_input.SU_storage) {
		player_input.SU_storage = new SU_Storage in player_input;
	}

	return player_input.SU_storage;
}

function SUST_Logger(message: string, optional informGUI: bool) {
	LogChannel('SUST', message);
	
	if (informGUI) {
		theGame.GetGuiManager().ShowNotification("SUST: " + message, 5, true);
	}
}
