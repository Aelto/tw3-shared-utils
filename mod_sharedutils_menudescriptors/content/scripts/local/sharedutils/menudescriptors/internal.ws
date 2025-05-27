////////////////////////////////////////////////////////////////////////////////
//   PRIVATE INTERFACE - do not extend, wrap, or modify code below this line  //
////////////////////////////////////////////////////////////////////////////////

@addField(CR4IngameMenu)
var su_menu_descriptors: array<SU_MenuDescriptor>;

@addField(CR4IngameMenu)
var su_menu_stack: array<string>;

@wrapMethod(CR4IngameMenu)
function OnShowOptionSubmenu(actionType: int, menuTag: int, id: string) {
  var descriptor: SU_MenuDescriptor;
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

  return wrappedMethod(actionType, menuTag, id);
}

@wrapMethod(CR4IngameMenu)
function OnOptionPanelNavigateBack() {
  var descriptor: SU_MenuDescriptor;
  var should_remove: bool;
  var menu_left: string;
  var i: int;

  theGame.GetGuiManager().ShowNotification("", 0);
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
  var message: string;
  var result: bool;
  var i: int;

  result = wrappedMethod(optionName, value);

  if (!value) {
    theGame.GetGuiManager().ShowNotification("", 0);
    return result;
  }

  LogChannel('SUMD', "OnOptionSelectionChanged(), optionName=" + optionName);

  for (i = 0; i < this.su_menu_descriptors.Size(); i += 1) {
    descriptor = this.su_menu_descriptors[i];

    message += descriptor.onOptionHovered(optionName);
  }

  if (message == "") {
    theGame.GetGuiManager().ShowNotification("", 0);
  }
  else {
    theGame.GetGuiManager().ShowNotification(message, -1);
  }

  return result;
}

class SU_MenuDescriptorInternal {
  private var option_hover_listeners: array<SU_MenuDescriptor_OptionDescription>;
  private var menu_scope: string;

  public final function enteredAt(menu: string) {
    this.menu_scope = menu;
    this.option_hover_listeners.Clear();
  }

  public final function didEnterAt(menu: string): bool {
    return this.menu_scope == menu;
  }

  public final function onOptionHovered(option: name): string {
    var output: string;
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
    }

    return output;
  }

  protected final function onHover(
    option_id: name,
    /// if the popup must contain a raw unlocalized string then this parameter
    /// can provide it:
    optional description: string,
    /// if the popup must contain a localized string then this parameter can
    /// provide the key of that localized string:
    optional description_loc_key: string
  ) {
    this.option_hover_listeners.PushBack(
      SU_MenuDescriptor_OptionDescription(
        option_id,
        description,
        description_loc_key
      )
    );
  }
}

struct SU_MenuDescriptor_OptionDescription {
  var option_id: name;
  var description: string;
  var description_loc_key: string;
}
