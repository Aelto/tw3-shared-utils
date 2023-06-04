state Render in SUOL_Manager {
	event OnEnterState(previous_state_name: name) {
		super.OnEnterState(previous_state_name);
		SUOL_Logger("Entering state [Render]");

		this.Render_main();
	}

	entry function Render_main() {
		if (!thePlayer.IsCiri()) {
			this.renderingLoop();
		}

		parent.GotoState('Idle');
	}

	latent function renderingLoop() {
		var sprite: CScriptedFlashSprite;
		var oneliner: SU_Oneliner;
		var oneliners_count: int;
		var i: int;

		var player_position: Vector;
		var screen_position: Vector;
		screen_position = thePlayer.GetWorldPosition();
		player_position = thePlayer.GetWorldPosition();

		while (true) {
			oneliners_count = parent.oneliners.Size();

			if (oneliners_count <= 0) {
				break;
			}

			player_position = thePlayer.GetWorldPosition();

			for (i = 0; i < oneliners_count; i += 1) {
				oneliner = parent.oneliners[i];
				sprite = parent.module_flash.GetChildFlashSprite("mcOneliner" + oneliner.id);

				if (!oneliner.getVisible(player_position)) {
					sprite.SetVisible(false);
					continue;	
				}

				if (oneliner.getScreenPosition(parent.module_hud, screen_position)) {
					sprite.SetPosition(screen_position.X, screen_position.Y);
					sprite.SetVisible(true);
				} else {
					sprite.SetVisible(false);
				}
			}

			SleepOneFrame();
		}
	}
}

/// The function returns true if the position in visible on the screen, false if
/// it is not.
function SUOL_worldToScreenPosition(hud: CR4ScriptedHud, world_position: Vector, out screen_position: Vector): bool {
	if (!theCamera.WorldVectorToViewRatio(world_position, screen_position.X, screen_position.Y)) {
		return false;
	}

	screen_position.X = (screen_position.X + 1) / 2;
	screen_position.Y = (screen_position.Y + 1) / 2;

	// at this point, screen_position is a normalized [0;1] vector, the GetScale
	// function transforms it into non normlized screen coordinates:
	screen_position = hud.GetScaleformPoint(screen_position.X, screen_position.Y);

	return true;
}
