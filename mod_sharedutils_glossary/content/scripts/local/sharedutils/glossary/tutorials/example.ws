////////////////////////////////////////////////////////////////////////////////
// The glossary tutorial module calls this function whenever the tutorial panel
// is displayed. The list of custom entries is constructed off the `entries`
// array that is provided to this function.
//
// You can wrap the function and append entries there, the parameter is marked
// as `out` which means any change to the list will affect the final result.
// For this reason prefer adding items but not removing them, as it could have
// an effect on the tutorials that were added by other mods.
@wrapMethod
function SU_populateTutorialEntries(
	out entries: array<SU_GlossaryTutorialEntry>
) {
	var tutorial: SU_GlossaryTutorialEntry;

	wrappedMethod(entries);
	if (!thePlayer.sugt_example_enabled) {
		return;
	}

	// Keep the example icon at 64 by 64, including with upscaled icon textures.
	tutorial = SU_createGlossaryTutorialEntryRaw(
		'SUGTentryUniqueIdExample',
		"SharedUtils - Custom Tutorial Entries",
		'SharedutilsCustomTutorialEntries',
		"Custom tutorial entry example",
		"This is a custom tutorial entry added through SharedUtils.",
		true,
		"icons/inventory/books/book_1.png",
		64.0f,
		64.0f
	);

	if (thePlayer.sugt_example_image_changed) {
		tutorial.image_path = "icons/inventory/scrolls/scroll1.dds";
	}

	entries.PushBack(tutorial);
}

////////////////////////////////////////////////////////////////////////////////
// utility exec functions so you can test the example in your game:

exec function SUGT_example() {
	thePlayer.SUGT_SetExampleEnabled(true);
	Log("SUGT | Example tutorial enabled. Reopen Tutorials to view it.");
}

exec function SUGT_exampleRemove() {
	if (!thePlayer.sugt_example_enabled) {
		Log("SUGT | Example tutorial entry was not found.");
		return;
	}

	thePlayer.SUGT_SetExampleEnabled(false);
	Log("SUGT | Example tutorial disabled. Reopen Tutorials to remove it.");
}

exec function SUGT_exampleChangeImage() {
	if (!thePlayer.sugt_example_enabled) {
		Log("SUGT | Example tutorial entry was not found.");
		return;
	}

	thePlayer.SUGT_ChangeExampleImage();
	Log("SUGT | Example tutorial image changed. Reopen Tutorials to view it.");
}

////////////////////////////////////////////////////////////////////////////////
// you won't really need this code for your logic, it's there so the example
// does not do anything unless activated by the exec functions above:

@addField(CR4Player)
var sugt_example_enabled: bool;

@addField(CR4Player)
var sugt_example_image_changed: bool;

@addMethod(CR4Player)
function SUGT_SetExampleEnabled(enabled: bool) {
	this.sugt_example_enabled = enabled;
	this.sugt_example_image_changed = false;
}

@addMethod(CR4Player)
function SUGT_ChangeExampleImage() {
	this.sugt_example_image_changed = true;
}
