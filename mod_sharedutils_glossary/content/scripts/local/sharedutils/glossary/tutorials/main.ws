// CREDITS: Code written and offered to the sharedutils collection by Relapse.

function SUGT_getManager(): SU_GlossaryTutorialManager {
	return thePlayer.getSharedutilsGlossaryTutorialManager();
}

// The caller supplies a fresh array. Mods wrap this hook to append their entries
function SU_populateTutorialEntries(out entries: array<SU_GlossaryTutorialEntry>) {}

function SU_getGlossaryTutorialEntry(tag: name): SU_GlossaryTutorialEntry {
	return SUGT_getManager().getEntry(tag);
}

function SU_createGlossaryTutorialEntryRaw(
	entry_unique_id: name,
	drop_down_label: string,
	drop_down_tag: name,
	title: string,
	description: string,
	is_new: bool,
	image_path: string,
	optional image_width: float,
	optional image_height: float
): SU_GlossaryTutorialEntry {
	var tutorial: SU_GlossaryTutorialEntry;

	if (entry_unique_id == '') {
		LogChannel('SUGT', "Cannot create tutorial entry: entry_unique_id is empty");
		return NULL;
	}

	if (drop_down_tag == '') {
		LogChannel('SUGT', "Cannot create tutorial entry: drop_down_tag is empty");
		return NULL;
	}

	if (title == "") {
		LogChannel('SUGT', "Cannot create tutorial entry: title is empty");
		return NULL;
	}

	tutorial = new SU_GlossaryTutorialEntry in thePlayer;

	tutorial.entry_unique_id = entry_unique_id;

	tutorial.drop_down_label = drop_down_label;
	tutorial.drop_down_tag = drop_down_tag;

	tutorial.title = title;
	tutorial.description = description;

	tutorial.is_new = is_new;

	if (image_path == "") {
		tutorial.image_path = "empty_texture.PNG";
	}
	else {
		tutorial.image_path = image_path;
	}

	// These optional bounds control display size independently of texture resolution.
	tutorial.image_width = image_width;
	tutorial.image_height = image_height;

	return tutorial;
}

function SU_createGlossaryTutorialEntryLocKeys(
	entry_unique_id: name,
	drop_down_label_key: string,
	drop_down_tag: name,
	title_key: string,
	description_key: string,
	is_new: bool,
	image_path: string,
	optional image_width: float,
	optional image_height: float
): SU_GlossaryTutorialEntry {
	return SU_createGlossaryTutorialEntryRaw(
		entry_unique_id,
		GetLocStringByKeyExt(drop_down_label_key),
		drop_down_tag,
		GetLocStringByKeyExt(title_key),
		GetLocStringByKeyExt(description_key),
		is_new,
		image_path,
		image_width,
		image_height
	);
}