:: update the /release directory with:
:: - the mod menu in /release/bin
:: - the mod DLC in /release/dlc
:: - the mod content in /release/mod

call variables.cmd
call bundle.bat

rmdir "%modpath%\release" /s /q
mkdir "%modpath%\release"


:: first the mods
mkdir "%modpath%\release\mods\"
XCOPY "%modpath%\mod_shared_utils_mappins\" "%modpath%\release\mods\mod_shared_utils_mappins\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_dialogChoices\" "%modpath%\release\mods\mod_sharedutils_dialogChoices\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_journalquest\" "%modpath%\release\mods\mod_sharedutils_journalquest\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_npcInteraction\" "%modpath%\release\mods\mod_sharedutils_npcInteraction\" /e /s /y

:: then the dlcs
mkdir "%modpath%\release\dlc\"
XCOPY "%modpath%\shared-utils\packed\" "%modpath%\release\dlc\dlcsharedutils\" /e /s /y