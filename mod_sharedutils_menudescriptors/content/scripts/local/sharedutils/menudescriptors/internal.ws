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
  this.SUMD_displayMessage(message_fallback);

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

  // clear fallback and hide popup:
  this.su_menu_message_fallback_cache = "";
  this.SUMD_displayMessage("");

  menu_left = this.su_menu_stack.PopBack();
  LogChannel('SUMD', "OnOptionPanelNavigateBack(), menu_left=" + menu_left);

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
  var descriptor: SU_MenuDescriptor;
  var message_fallback: string;
  var current_menu: name;
  var message: string;
  var result: bool;
  var i: int;

  result = wrappedMethod(optionName, value);

  if (!value) {
    this.su_menu_hovered_out_count += 1;

    if (this.su_menu_hovered_out_count > 15) {
      this.SUMD_displayMessage("");
      return result;
    }

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

    message += descriptor.onOptionHovered(current_menu, optionName);
  }

  this.SUMD_displayMessage(message);

  return result;
}


@addMethod(CR4IngameMenu)
function SUMD_displayMessage(message: string) {
  var duration: float = -1;

  if (message == "") {
    if (this.su_menu_message_fallback_cache != "") {
      message = this.su_menu_message_fallback_cache;
    }
  }

  if (message == this.su_menu_message_cache) {
    return;
  }

  this.su_menu_message_cache = message;

  if (message == "") {
    duration = 0;
  }

  theGame.GetGuiManager().ShowNotification(message, duration);
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

  public final function onOptionHovered(menu: name, option: name): string {
    var output: string;
    var dynamic: bool;
    var i: int;


    for (i = 0; i < this.option_hover_listeners.Size(); i += 1) {
      if (this.option_hover_listeners[i].option_id != option) {
        continue;
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
        theGame.GetInGameConfigWrapper().GetVarValue(menu, option),
        output
      );
    }

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
    /// if set to true, the system will redirect the current description that
    /// may have been obtained from `description` or `description_loc_key`
    /// and send them to 

    optional dynamic_description: bool
  ) {
    this.option_hover_listeners.PushBack(
      SU_MenuDescriptor_OptionDescription(
        option_id,
        description,
        description_loc_key,
        false // dynamic_description
      )
    );

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
  ) {
    this.option_hover_listeners.PushBack(
      SU_MenuDescriptor_OptionDescription(
        option_id,
        description,
        description_loc_key,
        true // dynamic_description
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

  private final function dynamicDescription(
    menu: name,
    option: name,
    value: string,
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
}
