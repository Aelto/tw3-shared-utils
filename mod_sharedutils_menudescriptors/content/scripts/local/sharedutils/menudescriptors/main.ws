/// create a class that extends SU_MenuDescriptor, override `function build()`
/// to add multiple calls to:
///
/// this.OnHover('FieldId', "RawUnlocalizedString", "localized_string_key");
///
/// in it to handle any hovered field in order to display popups with the
/// provided strings. If a localized string key is provided then it will use the
/// localized string, otherwise it will use the raw unlocalized string. Both
/// strings are optional and only one is enough.
abstract class SU_MenuDescriptor extends SU_MenuDescriptorInternal {
  public function build();
}

/// @wrapMethod() this function to add your instance to the array when `menu`
/// corresponds to the mod menu you want your descriptor to work in.
///
/// Make sure to keep calling wrappedMethod(menu, descriptors); so other mods
/// keep working.
/// 
/// The sharedutils module will take care of the lifetime of that descriptor so
/// it is automatically destroyed once the player exits that menu, while keeping
/// the instance alive for this menu and any of its sub-menus
@addMethod(CR4IngameMenu)
function SU_onMenuEntered(menu: string, out descriptors: array<SU_MenuDescriptor>) {}
