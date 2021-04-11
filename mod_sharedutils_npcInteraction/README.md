# NPC interaction
Offers an API to listen for the OnInteraction event. This allows any mod to add an eventlistener without having to edit the vanilla code.

## Using it

The mod offers a class that you should extend, this class then has two properties to override. The base class is `SU_InteractionEventListener` and the two properties are:
 - the attribute `tag: String` that is used to identify event listeners
 - the method `run()` that is run every time the player interacts with the NPC

You can see an example implementation in the [`example/main.ws`](example/main.ws) file.

## Important information

The list of event listeners does not persist in the save, meaning you have to add the event back every time a loading screen appears. **Unless** you add the persistent attribute `onInteractionEventListeners` to the `w2ent` you used to spawn the entity. So this will only work with custom made NPCs as you can't realistically edit the `w2ent` file of every NPC in the game.