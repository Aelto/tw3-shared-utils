@addField(CR4Player)
var sharedutils_glossary_tutorials: SU_GlossaryTutorialManager;

@addMethod(CR4Player)
function getSharedutilsGlossaryTutorialManager(): SU_GlossaryTutorialManager {
	if (!this.sharedutils_glossary_tutorials) {
		this.sharedutils_glossary_tutorials = new SU_GlossaryTutorialManager in this;
	}

	return this.sharedutils_glossary_tutorials;
}

@wrapMethod(CR4GlossaryTutorialsMenu)
function PopulateData() {
	var su_manager: SU_GlossaryTutorialManager;
	var su_previous_menu: CR4GlossaryTutorialsMenu;
	var su_previous_list_published: bool;
	var su_data_array: CScriptedFlashArray;

	su_manager = SUGT_getManager();

	// Get mod added entries for the current list before vanilla publishes any rows.
	su_manager.populateEntries();
	su_previous_menu = su_manager.populating_menu;
	su_previous_list_published = su_manager.list_published;
	su_manager.populating_menu = this;
	su_manager.list_published = false;

	wrappedMethod();

	// Vanilla skips SetFlashArray when it has no tutorial rows
	if (!su_manager.list_published && su_manager.entries.Size() > 0) {
		su_data_array = m_flashValueStorage.CreateTempFlashArray();

		m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME, su_data_array);
		m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(su_data_array.GetLength() > 0));
	}

	// Restore the outer call's context if another list rebuild ran inside it.
	su_manager.populating_menu = su_previous_menu;
	su_manager.list_published = su_previous_list_published;
}

// This uses a native wrapper, so it requires a REDkit-precompiled script blob (for now...)
@wrapMethod(CScriptedFlashValueStorage)
function SetFlashArray(key: string, value: CScriptedFlashArray) {
	var su_manager: SU_GlossaryTutorialManager;

	if (key == "glossary.tutorials.list" && thePlayer) {
		su_manager = SUGT_getManager();
		if (su_manager.populating_menu) {
			su_manager.populating_menu.SUGT_AppendTutorialEntries(this, value);
		}
	}

	wrappedMethod(key, value);
}

// Build custom rows on the menu so category expansion and selection retain vanilla behavior
@addMethod(CR4GlossaryTutorialsMenu)
function SUGT_AppendTutorialEntries(
	storage: CScriptedFlashValueStorage,
	value: CScriptedFlashArray
) {
	var su_manager: SU_GlossaryTutorialManager;
	var su_entry: SU_GlossaryTutorialEntry;
	var su_data_object: CScriptedFlashObject;
	var i: int;

	if (storage != m_flashValueStorage || !value) return;

	su_manager = SUGT_getManager();
	su_manager.list_published = true;

	for (i = 0; i < su_manager.entries.Size(); i += 1) {
		su_entry = su_manager.entries[i];
		if (!su_entry) {
			continue;
		}

		su_data_object = m_flashValueStorage.CreateTempFlashObject();

		su_data_object.SetMemberFlashUInt(
			"tag",
			NameToFlashUInt(su_entry.entry_unique_id)
		);
		su_data_object.SetMemberFlashString(
			"dropDownLabel",
			su_entry.drop_down_label
		);
		su_data_object.SetMemberFlashString("dropDownIcon", su_entry.drop_down_icon);
		su_data_object.SetMemberFlashBool("isNew", su_entry.getIsNew());
		su_data_object.SetMemberFlashString("label", su_entry.getTitle());
		su_data_object.SetMemberFlashUInt(
			"dropDownTag",
			NameToFlashUInt(su_entry.drop_down_tag)
		);
		su_data_object.SetMemberFlashBool(
			"dropDownOpened",
			IsCategoryOpened(su_entry.drop_down_tag)
		);

		if (resetSelection) {
			su_data_object.SetMemberFlashBool("selected", false);
		}
		else {
			su_data_object.SetMemberFlashBool(
				"selected",
				(su_entry.entry_unique_id == currentTag)
			);
		}

		// The stock list icon is transparent, so no use in adding it
		value.PushBackFlashObject(su_data_object);
	}
}

@wrapMethod(CR4GlossaryTutorialsMenu)
function UpdateDescription(entryName: name) {
	var su_entry: SU_GlossaryTutorialEntry;
	var description: string;

	su_entry = SUGT_getManager().getEntry(entryName);
	if (su_entry) {
		description = ReplaceTagsToIcons(su_entry.getDescription());

		m_fxSetEntryTag.InvokeSelfOneArg(FlashArgString(NameToString(su_entry.entry_unique_id)));
		m_fxSetTitle.InvokeSelfOneArg(FlashArgString(su_entry.getTitle()));
		m_fxSetText.InvokeSelfOneArg(FlashArgString(description));
		return;
	}

	// A removed tutorial entry can leave a stale selection. Clear it.
	if (!m_journalManager.GetEntryByTag(entryName)) {
		currentTag = '';
		lastSentTag = '';
		m_fxSetEntryTag.InvokeSelfOneArg(FlashArgString(""));
		m_fxSetTitle.InvokeSelfOneArg(FlashArgString(""));
		m_fxSetText.InvokeSelfOneArg(FlashArgString(""));
		return;
	}

	wrappedMethod(entryName);
}

// Keep the menu's original layout while a custom image uses explicit bounds.
struct SU_GlossaryTutorialImageLayout {
	var width: float;
	var height: float;
	var auto_size: bool;
	var maintain_aspect_ratio: bool;
	var content_x: float;
	var content_y: float;
}

@addField(CR4GlossaryTutorialsMenu)
private var sugt_image_layout: SU_GlossaryTutorialImageLayout;

@addField(CR4GlossaryTutorialsMenu)
private var sugt_image_size_overridden: bool;

// Both dimensions must be positive to resize an image. The loader applies the
// bounds after loading, so high-resolution replacements keep the requested size
@addMethod(CR4GlossaryTutorialsMenu)
function SUGT_SetImageSize(
	optional image_width: float,
	optional image_height: float
) {
	var image_module: CScriptedFlashObject;
	var image_loader: CScriptedFlashObject;
	var content_loader: CScriptedFlashObject;

	image_module = m_flashModule.GetMemberFlashObject("mcGlossarySubModule");
	if (!image_module) {
		return;
	}

	image_loader = image_module.GetMemberFlashObject("mcLoader");
	if (!image_loader) {
		return;
	}

	content_loader = image_loader.GetMemberFlashObject("loader");
	if (image_width > 0.0f && image_height > 0.0f) {
		// Capture the original settings once, before the first sized image.
		if (!sugt_image_size_overridden) {
			sugt_image_size_overridden = true;

			sugt_image_layout.width = image_loader.GetMemberFlashNumber("width");
			sugt_image_layout.height = image_loader.GetMemberFlashNumber("height");
			sugt_image_layout.auto_size = image_loader.GetMemberFlashBool("autoSize");
			sugt_image_layout.maintain_aspect_ratio = image_loader.GetMemberFlashBool("maintainAspectRatio");
			sugt_image_layout.content_x = 0.0f;
			sugt_image_layout.content_y = 0.0f;
			if (content_loader) {
				sugt_image_layout.content_x = content_loader.GetMemberFlashNumber("x");
				sugt_image_layout.content_y = content_loader.GetMemberFlashNumber("y");
			}
		}

		image_loader.SetMemberFlashBool("autoSize", true);
		image_loader.SetMemberFlashBool("maintainAspectRatio", true);
		image_loader.SetMemberFlashNumber("width", image_width);
		image_loader.SetMemberFlashNumber("height", image_height);
	}
	else if (sugt_image_size_overridden) {
		sugt_image_size_overridden = false;

		// Restore native sizing for vanilla tutorials and entries without bounds.
		image_loader.SetMemberFlashNumber("width", sugt_image_layout.width);
		image_loader.SetMemberFlashNumber("height", sugt_image_layout.height);
		image_loader.SetMemberFlashBool("autoSize", sugt_image_layout.auto_size);
		image_loader.SetMemberFlashBool(
			"maintainAspectRatio",
			sugt_image_layout.maintain_aspect_ratio
		);

		// Auto-sizing centers the inner loader. Its offset also needs restoring.
		if (content_loader) {
			content_loader.SetMemberFlashNumber("x", sugt_image_layout.content_x);
			content_loader.SetMemberFlashNumber("y", sugt_image_layout.content_y);
		}
	}
}

@wrapMethod(CR4GlossaryTutorialsMenu)
function UpdateImage(tag: name) {
	var su_entry: SU_GlossaryTutorialEntry;
	var image_path: string;

	su_entry = SUGT_getManager().getEntry(tag);
	if (su_entry) {
		SUGT_SetImageSize(su_entry.image_width, su_entry.image_height);

		image_path = su_entry.getImagePath();
		if (image_path == "" || image_path == "empty_texture.PNG") {
			image_path = "textures/glossary/tutorials/empty_texture.png";
		}

		m_fxSetImage.InvokeSelfOneArg(FlashArgString(image_path));
		return;
	}

	SUGT_SetImageSize();

	// Clear the previous image if the selected journal tutorial has no image.
	m_fxSetImage.InvokeSelfOneArg(FlashArgString("textures/glossary/tutorials/empty_texture.png"));

	// A removed tutorial entry has no journal image to load
	// Keep the cleared image instead of passing its stale tag
	if (!m_journalManager.GetEntryByTag(tag)) {
		return;
	}

	wrappedMethod(tag);
}

@wrapMethod(CR4ListBaseMenu)
function OnEntryRead(tag: name) {
	var tutorialsMenu: CR4GlossaryTutorialsMenu;

	tutorialsMenu = (CR4GlossaryTutorialsMenu)this;

	if (tutorialsMenu) {
		if (SUGT_getManager().markEntryRead(tag)) {
			return true;
		}

		// Consume stale entry tags here before the native journal handler receives them
		if (!m_journalManager.GetEntryByTag(tag)) {
			return true;
		}
	}

	return wrappedMethod(tag);
}
