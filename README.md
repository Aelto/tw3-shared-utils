# tw3-shared-utils
A collection of utilities for modding the game

## utils

most utilities have an example folder and extensive comments explaining how to use them.

| Name (shortname) | Description | Dependencies (other modules it depends on) |
| ---- | ----------- | ------------------------------------------ |
| [Helpers (SUH)](mod_sharedutils_helpers/content/scripts/local/sharedutils/helpers) | Functions you may find useful while creating mods | |
| [Noticeboards](/mod_sharedutils_noticeboards/content/scripts/local/sharedutils/noticeboards/example.ws) | Detect when the player picks a notice from a noticeboard |   |
| [Journal Quest](/mod_sharedutils_journalquest/) | Create script based quests |  |
| [Custom bossbar](mod_sharedutils_custombossbar/content/scripts/local/sharedutils/custombossbar/globals.ws) | Three easy to use functions to use boss bars as progress bars |
| [Dialog choice](mod_sharedutils_dialogChoices/example/main.ws) | Display the dialogue choice UI whenever you want, and allows you to detect when the player picks a choice |  |
| [Dialog hover](mod_sharedutils_dialogHover/) | Detect when the player puts the cursor over a dialog choice | |
| [Glossary](mod_sharedutils_glossary/content/scripts/local/glossary/example.ws) | Add custom glossary entries with dynamic descriptions if needed | |
| [Mappins (SUMP)](/mod_sharedutils_mappins/example/) | Add custom markers on the player map & minimap | `Helpers` |
| [Oneliners/3D Markers (SUOL)](/mod_sharedutils_oneliners/) | Add floating text/image elements to the world | |
| [Custom cooldowns](mod_sharedutils_customcooldowns/example/main.ws) | Add custom cooldown icons to the player and to add event listeners for when they finish |  |
| [NPC interaction](/mod_sharedutils_npcInteraction/README.md) | Run custom code when the player interacts with an NPC |  |
| [**DEPRECATED** Tiny Bootstrapper (SUTB)](mod_sharedutils_tiny_bootstrapper/) | _**DEPRECATED**: refer to the [`wrapMethod`](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/36241598/WS+Script+Compilation+Errors+overrides) for a merge free solution to bootstrap your mods from `CR4Player`'s `event OnSpawned`._ Bootstrap a persistent class after every reload automatically and with no extra merge for the end-users | `Storage`
| [**DEPRECATED** Storage (SUST)](mod_sharedutils_storage) | _**DEPRECATED**: refer to the [`addField`](https://cdprojektred.atlassian.net/wiki/x/vgApAg) for a merge free solution to store data in `CR4Player`._ Store persistent objects in the save with no extra merge. Most sharedutils module rely on this one for internal data storage.  | |

## Shipping mods that depend on shared-utils
The code available in this repository can be considered public domain. You may use, edit, and share this code with no restriction. Editing sharedutils rather than submitting PRs may be counter productive though, but you can freely ship the sharedutils alongside your own mods on any website even those with monetary rewards.

The primary goal of the shared-utils package is to simplify mod making and reduce complexity while shipping mods by decreasing the amount of merge conflicts for the end-users.

# Known mods that are using Sharedutils
- [Faen/Progress-On-The-Path](https://github.com/Faen668/Progress-On-The-Path)
- [Faen/Botanist](https://github.com/Faen668/Botanist)
- [RasitAyaz/Alternative-Radial-Menu](https://www.nexusmods.com/witcher3/mods/8237)
- [Aelto/tw3-random-encounters-reworked](https://github.com/Aelto/tw3-random-encounters-reworked)
- [Aelto/tw3-crow](https://github.com/Aelto/tw3-crow)
- [Aelto/tw3-a-gwent-empire](https://github.com/Aelto/tw3-a-gwent-empire)
- [Aelto/tw3-consumables-on-cooldown](https://github.com/Aelto/tw3-consumables-on-cooldowns)