
function SU_getStorage(): SU_Storage {
	SUST_Logger("SU_getStorage()");

	return SU_getStorageFromInput(thePlayer.GetInputHandler());
}

function SU_getStorageFromInput(player_input: CPlayerInput): SU_Storage {
	SUST_Logger("SU_getStorageFromInput()");

	if (!player_input.SU_storage) {
		SUST_Logger("SU_getStorageFromInput(), no storage, instantiating");

		player_input.SU_storage = new SU_Storage in player_input;
	}

	return player_input.SU_storage;
}

function SU_getBuffer(): SU_Storage {
	SUST_Logger("SU_getBuffer()");

	return SU_getBufferFromInput(thePlayer.GetInputHandler());
}

function SU_getBufferFromInput(player_input: CPlayerInput): SU_Storage {
	SUST_Logger("SU_getBufferFromInput()");

	if (!player_input.SU_buffer) {
		SUST_Logger("SU_getBufferFromInput(), no buffer, instantiating");

		player_input.SU_buffer = new SU_Storage in player_input;
	}

	return player_input.SU_buffer;
}

function _sustuninstall(tag: string) {
	var storage: SU_Storage;

	storage = SU_getStorage();

	if (storage.hasItem(tag)) {
		storage.removeItem(storage.getItem(tag));
	}
}
exec function sustuninstall(tag: string) {
	_sustuninstall(tag);
}

function SUST_Logger(message: string, optional informGUI: bool) {
	LogChannel('SUST', message);
	
	if (informGUI) {
		theGame.GetGuiManager().ShowNotification("SUST: " + message, 5, true);
	}
}
