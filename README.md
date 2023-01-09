# tw3-shared-utils
A collection of utilities for modding the game

## utils

most utilities have an example folder and extensive comments explaining how to use them.

- [NPC interaction](/mod_sharedutils_npcInteraction/README.md) offers a simple way to run custom code when the player interacts with an NPC.
- [Noticeboards](/mod_sharedutils_noticeboards/content/scripts/local/sharedutils/noticeboards/example.ws) offers a simple way to detect when the player picks a notice from a noticeboard.
- [Mappins](/mod_sharedutils_mappins/example/) offers a simple way to add custom markers on the player map & minimap
- [Journal Quest](/mod_sharedutils_journalquest/) offers a way to create script based quests
- [Helpers](mod_sharedutils_helpers/content/scripts/local/sharedutils/helpers) contains a set of utility functions you may find useful while creating mods
- [Custom cooldowns](mod_sharedutils_customcooldowns/example/main.ws) allows you to add custom cooldown icons to the player and to add event listeners for when they finish
- [Custom bossbar](mod_sharedutils_custombossbar/content/scripts/local/sharedutils/custombossbar/globals.ws) gives you three easy to use functions to use boss bars as progress bars
- [Dialog choice](mod_sharedutils_dialogChoices/example/main.ws) lets you display the dialogue choice UI whenever you want, and allows you to detect when the player picks a choice
- [Dialog hover](mod_sharedutils_dialogHover/) lets you detect when the player puts the cursor over a dialog choice
- [Tiny Bootstrapper](mod_sharedutils_tiny_bootstrapper/) allows you to bootstrap a persistent class after every reload automatically and with no extra merge for the end-users
- [Storage](mod_sharedutils_storage) allows you to store persistent objects in the save with no extra merge. Most sharedutils module rely on this one for internal data storage
- [Glossary](mod_sharedutils_glossary/content/scripts/local/glossary/example.ws) allows you to add custom glossary entries with dynamic descriptions if needed

## Shipping mods that depend on shared-utils
The code available in this repository can be considered public domain. You may use, edit, and share this code with no restriction. Editing sharedutils rather than submitting PRs may be counter productive though, but you can freely ship the sharedutils alongside your own mods on any website even those with monetary rewards.

The primary goal of the shared-utils package is to simplify mod making and reduce complexity while shipping mods by decreasing the amount of merge conflicts for the end-users.
