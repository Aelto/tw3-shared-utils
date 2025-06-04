# Sharedutils Menu Descriptor
The Menu Descriptor modules allows mod authors to display more information when
the user hovers over entries in mod menus. The sharedutils module handles the logic
of keeping track which menu is currently opened, and which descriptor instances
should be kept alive for maximum performances.

# Implementation example
Assuming a XML menu like this:
```xml
<Group id="RERmain" displayName="Mods.rer_name.rer_main_settings">
  <PresetsArray></PresetsArray>
  <VisibleVars>
    <Var id="RERmodEnabled" displayName="rer_mod_enabled" displayType="TOGGLE"></Var>
    <Var id="RERperformanceMode" displayName="rer_performance_mode" displayType="TOGGLE"></Var>

    <Var id="RERgeneralIntensity" displayName="rer_general_intensity" displayType="SLIDER;0;500;500"/>

    <Var id="RERexternalFactors" displayName="rer_external_factors" displayType="SLIDER;0;10;10"/>

    <Var id="RERmodVersion" displayName="rer_mod_version" displayType="SLIDER;0;100;10000"></Var>
  </VisibleVars>
</Group>
```

Creating a menu descriptor for it requires the following code:
```js
class RER_MainMenuDescriptor extends SU_MenuDescriptor {
  public function build() {
    // displaying raw unlocalized strings when these fields are hovered:
    this.onHover(
      'RERperformanceMode',
      "Enabling <font color='#CD7D03'>Performance Mode</font> will alter how the mod operates to focus even more on performances, sometimes by ignoring the values from the menu to use pre-defined ones, or by disabling features like the Ecosystem for a smoother experience at the cost of immersion.<br/><br/>Changes to the option requires a reload of the save to take effect."
    );

    this.onHover(
      'RERgeneralIntensity',
      "This slider allows you to instantly speed up or slow down every system in the mod at once, the values of each individual system are then multiplied by the % you specify here.<br/><br/>If you feel like there is too much happening then turning it down to 50% is the way to go, or if you'd like more of what the mod offers then turning it up to 200% will do exactly that."
    );

    // displaying a localized string when this field is hovered:
    this.onHover('RERmodVersion',, "rer_mod_version_on_hover");

    // the fallback message is displayed when there is nothing else to display,
    // if entering a menu or hovering an entry doesn't result in any message then
    // the fallback is used (if it isn't empty either).
    //
    // You can skip the first string and pass a string_key as a second parameter
    // for a localized message.
    this.withFallbackMessage(
      "The main menu for RER, in there you'll find various settings to initialize the mod, turn it off, or quickly scale up/down the intensity of every system it offers."
    );
  }
}

@wrapMethod(CR4IngameMenu)
function SU_onMenuEntered(menu: string, out descriptors: array<SU_MenuDescriptor>) {
  wrappedMethod(menu, descriptors);

  if (menu == "rer_main_settings") {
    descriptors.PushBack(new RER_MainMenuDescriptor in this);
  }
}
```

## Dynamic descriptions
In some unique scenarios you may want to dynamically change the description
based on the value of the field that's being hovered. In such case you can
replace calls to `this.onHover` to `this.onHoverDynamic` to indicate that you may edit the description afterward.

Once this is done, the description obtained from either the hardcoded description or from the localization key you pass (2nd and 3th parameters to `this.onHover()` or its `dynamic` variant in this case) will be sent through a method called `dynamicDescription`.

> Note that if you do not need dynamic strings then you can skip that method entirely and not implement it as shown in the example above.

Here is a complete example:
```js
class RER_MainMenuDescriptor extends SU_MenuDescriptor {
  public function build() {
    this.onHoverDynamic(
      'RERgeneralIntensity',
      "This slider allows you to instantly speed up or slow down every system in the mod at once, the values of each individual system are then multiplied by the % you specify here.<br/><br/>If you feel like there is too much happening then turning it down to 50% is the way to go, or if you'd like more of what the mod offers then turning it up to 200% will do exactly that."
    );
  }

  protected function dynamicDescription(
    /// the current menu
    menu: string,
    /// the currently hovered field
    option: name,
    /// the current description that's going to be displayed
    description: string
  ): string {
    var value: float;

    if (option == 'RERgeneralIntensity') {
      value = StringToFloat(
        theGame
          .GetInGameConfigWrapper()
          .GetVarValue('RERmain', option)
      );

      if (value >= 200.0) {
        // add a small note when the value is above 5 for example:
        return description + "<br/><br/>A value above 200% can cause performance issues due to the amount of spawned enemies, adjust encounter settings accordingly.";
      }
    }

    // unchanged description for any result we do not handle.
    return description;
  }
}

@wrapMethod(CR4IngameMenu)
function SU_onMenuEntered(menu: string, out descriptors: array<SU_MenuDescriptor>) {
  wrappedMethod(menu, descriptors);

  if (menu == "rer_main_settings") {
    descriptors.PushBack(new RER_MainMenuDescriptor in this);
  }
}
```

# Credits
- The discovery of the events this sharedutils module relies on was made by [MrCementKnight](https://next.nexusmods.com/profile/MrCementKnight?gameId=952).