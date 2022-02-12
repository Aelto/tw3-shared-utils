# NPC interaction
Offers an API to listen for the OnInteraction event. This allows any mod to add an eventlistener without having to edit the vanilla code.

## Using it

The mod offers a class that you should extend, this class then has two properties to override. The base class is `SU_InteractionEventListener` and the two properties are:
 - the attribute `tag: String` that is used to identify event listeners
 - the method `run()` that is run every time the player interacts with the NPC

You can see an example implementation in the [`example/main.ws`](example/main.ws) file.

### Global event listeners
If you wish to add a global interaction event listener, refer to the example in [`example/global_npc_interaction.ws`](example/global_npc_interaction.ws) file.

Once you have added your state for the global event listener, create a mod bundle with an xml file, copy this content and
edit the `name="MyGlobalEventListener"` attribute so that it corresponds with your new state:
```xml
<?xml version="1.0" encoding="UTF-16"?>
<redxml>
  <definitions>
    <items>

      <!--
        the fake item whose name is the name of your global event listener
        state.
       -->
      <item name="MyGlobalEventListener">
        <!-- make sure to add this tag or else the item won't be detected -->
        <tags>SU_NpcInteraction_GlobalEventListener</tags>
      </item>
      
    </items>
  </definitions>
</redxml>
```

## Important information

The list of event listeners does not persist in the save for some NPCs, such as guards, because they can die and respawn and so it seems they are simply recrated from scratch every loading screen.