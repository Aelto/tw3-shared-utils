////////////////////////////////////////////////////////////////////////////////
//   PRIVATE INTERFACE - do not extend, wrap, or modify code below this line  //
////////////////////////////////////////////////////////////////////////////////

@addField(CR4IngameMenu)
var su_menu_descriptors: array<SU_MenuDescriptor>;

@addField(CR4IngameMenu)
var su_menu_stack: array<string>;

/// cache the previous message so avoid sending a duplicate and causing the
/// entrance animation on the popup to play again.
@addField(CR4IngameMenu)
var su_menu_message_cache: string;

/// the fallback message is displayed when there is nothing else to display,
/// if entering a menu or hovering an entry doesn't result in any message then
/// the fallback is used (if it isn't empty either).
@addField(CR4IngameMenu)
var su_menu_message_fallback_cache: string;

/// in order to filter out uninteresting hover OUT events, we can compare
/// them to the last hover IN source.
@addField(CR4IngameMenu)
var su_menu_hovered_option: name;

/// counts how many hover OUT events were received since the last hover IN.
/// A high OUT count can indicate the user is scrolling, or that new entries
/// were added to the menu and that it is safer to cancel the last hove IN
/// event.
@addField(CR4IngameMenu)
var su_menu_hovered_out_count: int;

/// true while the banner displays one of our messages rather than the vanilla
/// Accessibility preset description.
@addField(CR4IngameMenu)
var su_menu_banner_owned: bool;

@addField(CR4IngameMenu)
var su_menu_fx_show_banner: CScriptedFlashFunction;

@wrapMethod(CR4IngameMenu)
function OnConfigUI() {
  var result: bool;

  result = wrappedMethod();

  this.m_flashModule
    .GetChildFlashSprite("mcOptionListModule")
    .GetChildFlashSprite("tooltip")
    .GetMemberFlashObject("textField")
    .SetMemberFlashString("autoSize", "left");

  return result;
}

@wrapMethod(CR4IngameMenu)
function OnShowOptionSubmenu(actionType: int, menuTag: int, id: string) {
  var descriptor: SU_MenuDescriptor;
  var message_fallback: string;
  var previous_size: int;

  LogChannel('SUMD', "OnShowOptionSubmenu(), id=" + id);

  previous_size = this.su_menu_descriptors.Size();
  this.SU_onMenuEntered(id, this.su_menu_descriptors);

  for (previous_size; previous_size < this.su_menu_descriptors.Size(); previous_size += 1) {
    descriptor = this.su_menu_descriptors[previous_size];

    if (descriptor) {
      descriptor.enteredAt(id);
      descriptor.build();
    }
  }

  this.su_menu_stack.PushBack(id);

  for (previous_size = 0; previous_size < this.su_menu_descriptors.Size(); previous_size += 1) {
    descriptor = this.su_menu_descriptors[previous_size];

    if (descriptor) {
      message_fallback += descriptor.getMessageFallback();
    }
  }
  this.su_menu_message_fallback_cache = message_fallback;
  this.SUMD_displayMessageForType(message_fallback);

  return wrappedMethod(actionType, menuTag, id);
}

@wrapMethod(CR4IngameMenu)
function OnOptionPanelNavigateBack() {
  var descriptor: SU_MenuDescriptor;
  var should_remove: bool;
  var menu_left: string;
  var i: int;

  this.su_menu_hovered_out_count = 0;
  this.su_menu_hovered_option = '';

  menu_left = this.su_menu_stack.PopBack();
  LogChannel('SUMD', "OnOptionPanelNavigateBack(), menu_left=" + menu_left);

  // clear fallback and hide banner:
  this.su_menu_message_fallback_cache = "";
  this.SUMD_displayMessageForType("");

  for (i = 0; i < this.su_menu_descriptors.Size(); i += 1) {
    descriptor = this.su_menu_descriptors[i];

    should_remove = true;
    if (descriptor) {
      should_remove = descriptor.didEnterAt(menu_left);
    }
    
    if (should_remove) {
      LogChannel('SUMD', "OnOptionPanelNavigateBack(), descriptor removed at index=" + i);
      this.su_menu_descriptors.Erase(i);
      i -= 1;
    }
  }

  return wrappedMethod();
}

@wrapMethod(CR4IngameMenu)
function OnOptionSelectionChanged(optionName: name, value: bool) {
  var display_type: SU_MenuDescriptor_DisplayType;
  var descriptor: SU_MenuDescriptor;
  var current_menu: string;
  var message: string;
  var result: bool;
  var i: int;

  result = wrappedMethod(optionName, value);

  if (!value) {
    if (optionName == this.su_menu_hovered_option || this.su_menu_hovered_out_count > 15) {
      this.SUMD_displayMessageForType("");
      return result;
    }

    this.su_menu_hovered_out_count += 1;

    // an unwanted OUT event was received which didn't match the last IN
    // entry name. Update optionName to simulate a IN event on the previous
    // hovered entry instead, let the logic handle duplicate IN events then
    optionName = this.su_menu_hovered_option;
    value = true;
  }
  else {
    // a hover IN was received, update adequate cache values:
    this.su_menu_hovered_out_count = 0;
    this.su_menu_hovered_option = optionName;
  }

  LogChannel('SUMD', "OnOptionSelectionChanged(), optionName=" + optionName);

  current_menu = this.su_menu_stack.Last();
  for (i = 0; i < this.su_menu_descriptors.Size(); i += 1) {
    descriptor = this.su_menu_descriptors[i];

    message += descriptor.onOptionHovered(current_menu, optionName, display_type);
  }

  this.SUMD_displayMessageForType(message, SUMD_DT_Automatic);

  return result;
}

@wrapMethod(CR4IngameMenu)
function OnOptionValueChanged(
  groupId: int,
  optionName: name,
  optionValue: string
) { 
  var display_type: SU_MenuDescriptor_DisplayType;
  var descriptor: SU_MenuDescriptor;
  var current_menu: string;
  var message: string;
  var result: bool;
  var i: int;

  result = wrappedMethod(groupId, optionName, optionValue);
  LogChannel('SUMD', "OnOptionValueChanged(), optionName=" + optionName);

  current_menu = this.su_menu_stack.Last();
  for (i = 0; i < this.su_menu_descriptors.Size(); i += 1) {
    descriptor = this.su_menu_descriptors[i];

    message += descriptor.onOptionValueChanged(current_menu, optionName, display_type);
  }

  if (message != "") {
    this.SUMD_displayMessageForType(message, display_type);
  }

  return result;
}

@addMethod(CR4IngameMenu)
function SUMD_displayMessageForType(
  message: string,
  optional display_type: SU_MenuDescriptor_DisplayType
) {
  if (message == "") {
    if (this.su_menu_message_fallback_cache != "") {
      message = this.su_menu_message_fallback_cache;
    }
  }

  switch (display_type) {
    case SUMD_DT_Popup:
      SUMD_displayMessagePopup(message);
      this.SUMD_releaseBanner(); // hide banners
      break;

    case SUMD_DT_BannerBottom:
      SUMD_displayMessageBannerBottom(message);
      theGame.GetGuiManager().ShowNotification("", 0); // hide popups
      break;

    // the SUMD_DT_Automatic case, or any other case we do not handle
    default:
      // Each line can contain roughly 130 characters before it wraps.
      // The bottom banner can have 6 lines before it clips, but at 6 lines it
      // is already close to clipping and obstructs a good part of the screen.
      //
      // For this reason we'll stop at 5 lines:
      
      if (SUMD_estimateBannerLines(message) > 5.0) {
        SUMD_displayMessagePopup(message);
        this.SUMD_releaseBanner(); // hide banners
      }
      else {
        SUMD_displayMessageBannerBottom(message);
        theGame.GetGuiManager().ShowNotification("", 0); // hide popups
      }
      break;
  }
}

function SUMD_estimateBannerLines(message: string): float {
	var character: string;
	var inside_tag: bool;
	var line_count: int;
	var line_length: int;
	var message_length: int;
	var i: int;

	// Normalize common line breaks
	message = StrLower(message);
	message = StrReplaceAll(message, "\r\n", "\n");
	message = StrReplaceAll(message, "\r", "\n");
	message = StrReplaceAll(message, "<br>", "\n");
	message = StrReplaceAll(message, "<br/>", "\n");
	message = StrReplaceAll(message, "<br />", "\n");
	message = StrReplaceAll(message, "<li>", "\n");
	message_length = StrLen(message);

	if (message_length == 0) {
		return 0;
  }

	line_count = 0;
	for (i = 0; i < message_length; i += 1) {
		character = StrMid(message, i, 1);

    // 0. no need to go further than 6 lines, as it's the limit for the banner
    if (line_count > 6) {
			break;
    }

    // 1. detect & skip characters inside HTML tags that start & end with <>
		if (character == "<") {
			inside_tag = true;
			continue;
		}

		if (character == ">" && inside_tag) {
			inside_tag = false;
			continue;
		}

		if (inside_tag) {
      continue;
    }

    // 2. a line break, stop counting the character in the current line and
    // directly increment the line_count.
		if (character == "\n") {
			line_count += 1;
			line_length = 0;
      continue;
		}

    // 3. regular characters that are neither inside tags, nor linebreaks.
    // 
    // Past a limit, we consider the line to be wrapped automatically due to the
    // banner's width. And we start a new line count.
    line_length += 1;
    if (character == "\t") {
      line_length += 4;
    }

    if (line_length >= 130) {
      line_count += 1;
      line_length = 0;
    }
	}

	if (line_count == 1 && line_length <= 0) {
		return 0;
  }

  // the `/ 130.0` part is there to still count the unfinished lines that could
  // cause the line_count to go from 5.0 (isn't above threshold) to 5.1 (is above)
	return line_count + (line_length / 130.0);
}

/// Prefer calling `SUMD_displayMessageForType` rather than this method directly
/// to benefit from the display type choice and/or the automatic picking logic.
@addMethod(CR4IngameMenu)
function SUMD_displayMessagePopup(message: string) {
  var duration: float = -1;

  if (message == this.su_menu_message_cache) {
    return;
  }

  this.su_menu_message_cache = message;

  if (message == "") {
    duration = 0;
  }

  theGame.GetGuiManager().ShowNotification(message, duration);
}

/// Messages are displayed in the banner the vanilla Accessibility menu uses for
/// its preset description, it sits under the option list of every options
/// panel and is driven by two flash functions: `updateBardsBalladText` for the
/// content and `showBardsBalladTooltip` for the visibility.
///
/// Prefer calling `SUMD_displayMessageForType` rather than this method directly
/// to benefit from the display type choice and/or the automatic picking logic.
@addMethod(CR4IngameMenu)
function SUMD_displayMessageBannerBottom(message: string) {
  if (message == this.su_menu_message_cache) {
    return;
  }

  this.su_menu_message_cache = message;

  if (message == "") {
    this.SUMD_releaseBanner();
    return;
  }

  this.su_menu_banner_owned = true;
  this.m_fxUpdateBardsBalladText.InvokeSelfOneArg(FlashArgString(message));
  this.SUMD_showBanner(true);
}

/// Gives the banner back to the vanilla game: the flash side caches the last
/// text it received and the scripts only refresh it when the options are
/// opened, so the Accessibility text has to be restored by hand.
@addMethod(CR4IngameMenu)
function SUMD_releaseBanner() {
  if (!this.su_menu_banner_owned) {
    return;
  }

  this.su_menu_banner_owned = false;
  this.UpdateBardsBalladTooltipText();
  this.SUMD_showBanner(
    this.su_menu_stack.Size() > 0
    && this.su_menu_stack.Last() == "option_accessibility"
  );
}

@addMethod(CR4IngameMenu)
function SUMD_showBanner(show: bool) {
  if (!this.su_menu_fx_show_banner) {
    this.su_menu_fx_show_banner = this.m_flashModule
      .GetMemberFlashFunction("showBardsBalladTooltip");
  }

  this.su_menu_fx_show_banner.InvokeSelfOneArg(FlashArgBool(show));
}

class SU_MenuDescriptorInternal {
  private var option_hover_listeners: array<SU_MenuDescriptor_OptionDescription>;
  private var menu_scope: string;

  private var message_fallback: string;

  public final function enteredAt(menu: string) {
    this.menu_scope = menu;
    this.option_hover_listeners.Clear();
  }

  public final function didEnterAt(menu: string): bool {
    return this.menu_scope == menu;
  }

  public final function onOptionHovered(
    menu: string,
    option: name,
    out display_type: SU_MenuDescriptor_DisplayType
  ): string {
    var output: string;
    var dynamic: bool;
    var i: int;

    for (i = 0; i < this.option_hover_listeners.Size(); i += 1) {
      if (this.option_hover_listeners[i].option_id != option) {
        continue;
      }

      if (this.option_hover_listeners[i].display_type != SUMD_DT_Automatic) {
        display_type = this.option_hover_listeners[i].display_type;
      }

      if (this.option_hover_listeners[i].description_loc_key != "") {
        output += GetLocStringByKey(this.option_hover_listeners[i].description_loc_key);
      }
      else {
        output += this.option_hover_listeners[i].description;
      }

      dynamic = dynamic
             || this.option_hover_listeners[i].dynamic_description;
    }

    if (dynamic) {
      output = this.dynamicDescription(
        menu,
        option,
        output
      );
    }

    return output;
  }

  public final function onOptionValueChanged(
    menu: string,
    option: name,
    out display_type: SU_MenuDescriptor_DisplayType
  ): string {
    var output: string;
    var i: int;

    for (i = 0; i < this.option_hover_listeners.Size(); i += 1) {
      if (this.option_hover_listeners[i].option_id != option) {
        continue;
      }

      // skip all non-dynamic listeners
      if (!this.option_hover_listeners[i].dynamic_description) {
        continue;
      }

      if (this.option_hover_listeners[i].display_type != SUMD_DT_Automatic) {
        display_type = this.option_hover_listeners[i].display_type;
      }

      if (this.option_hover_listeners[i].description_loc_key != "") {
        output += GetLocStringByKey(this.option_hover_listeners[i].description_loc_key);
      }
      else {
        output += this.option_hover_listeners[i].description;
      }
    }

    output = this.dynamicDescription(
      menu,
      option,
      output
    );

    return output;
  }

  public final function getMessageFallback(): string {
    return this.message_fallback;
  }

  protected final function onHover(
    option_id: name,
    /// if the popup must contain a raw unlocalized string then this parameter
    /// can provide it:
    optional description: string,
    /// if the popup must contain a localized string then this parameter can
    /// provide the key of that localized string:
    optional description_loc_key: string,
    /// if provided, you can force a type of display instead of relying on the
    /// automatic selection based on the message's length. Useful if your 
    /// message is too long but the automatic detection thinks it's too short or
    /// vice-versa.
    optional display_type: SU_MenuDescriptor_DisplayType
  ) {
    this.option_hover_listeners.PushBack(
      SU_MenuDescriptor_OptionDescription(
        option_id,
        description,
        description_loc_key,
        false, // dynamic_description
        display_type
      )
    );
  }

  /// like onHover but appends a dynamic variant that will go through
  /// dynamicDescription to be dynamically edited afterward.
  protected final function onHoverDynamic(
    option_id: name,
    /// if the popup must contain a raw unlocalized string then this parameter
    /// can provide it:
    optional description: string,
    /// if the popup must contain a localized string then this parameter can
    /// provide the key of that localized string:
    optional description_loc_key: string,
    /// if provided, you can force a type of display instead of relying on the
    /// automatic selection based on the message's length. Useful if your 
    /// message is too long but the automatic detection thinks it's too short or
    /// vice-versa.
    optional display_type: SU_MenuDescriptor_DisplayType
  ) {
    this.option_hover_listeners.PushBack(
      SU_MenuDescriptor_OptionDescription(
        option_id,
        description,
        description_loc_key,
        true, // dynamic_description
        display_type
      )
    );
  }

  /// Sets a popup that's displayed when no hover is currently being displayed
  /// after hovering out an entry.
  protected final function withFallbackMessage(
    /// if the popup must contain a raw unlocalized string then this parameter
    /// can provide it:
    optional description: string,
    optional description_loc_key: string
  ) {
    if (description_loc_key != "") {
      this.message_fallback = GetLocStringByKey(description_loc_key);
    }
    else {
      this.message_fallback = description;
    }
  }

  protected function dynamicDescription(
    menu: string,
    option: name,
    description: string
  ): string {
    return description;
  }
}

struct SU_MenuDescriptor_OptionDescription {
  var option_id: name;
  var description: string;
  var description_loc_key: string;
  var dynamic_description: bool;
  var display_type: SU_MenuDescriptor_DisplayType;
}

enum SU_MenuDescriptor_DisplayType {
  /// lets the framework pick the right display type based on the message length
  SUMD_DT_Automatic = 0,
  /// forces the use of the popup for this message
  SUMD_DT_Popup = 1,
  /// forces the use of the bottom banner that was introduced in the Remastered
  /// version of the game
  SUMD_DT_BannerBottom = 2
}
