# Custom map pins

Easily add map pins to the game with custom coordinates, icons, description and labels. Entirely through code without any bundling

## Using it

The [example file](example/main.ws) should show everything you need to know about the utility. If this is not enough then the [commented code](content/scripts/local/sharedutils/mappins.ws
) should guide you even more.

Basically, you create your new pin from the class `SU_MapPin` and set its information, then you call `thePlayer.addCustomPin(pin);` and you're done.

For the sake of simplicity there is no function to remove a pin from the list, there is only a function to add one `addCustomPin()`. To remove a pin from the list, simply iterate through `thePlayer.customMapPins` and `.Remove()` the pin you want to remove.