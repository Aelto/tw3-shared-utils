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
XCOPY "%modpath%\mod_sharedutils_custombossbar\" "%modpath%\release\mods\mod_sharedutils_custombossbar\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_customcooldowns\" "%modpath%\release\mods\mod_sharedutils_customcooldowns\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_damagemodifiers\" "%modpath%\release\mods\mod_sharedutils_damagemodifiers\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_dialogChoices\" "%modpath%\release\mods\mod_sharedutils_dialogChoices\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_dialogHover\" "%modpath%\release\mods\mod_sharedutils_dialogHover\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_helpers\" "%modpath%\release\mods\mod_sharedutils_helpers\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_journalquest\" "%modpath%\release\mods\mod_sharedutils_journalquest\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_mappins\" "%modpath%\release\mods\mod_sharedutils_mappins\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_noticeboards\" "%modpath%\release\mods\mod_sharedutils_noticeboards\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_npcInteraction\" "%modpath%\release\mods\mod_sharedutils_npcInteraction\" /e /s /y
XCOPY "%modpath%\mod_sharedutils_oneliners\" "%modpath%\release\mods\mod_sharedutils_oneliners\" /e /s /y
XCOPY "%modpath%\mod0000_sharedutilsmappinsfhudpatch\" "%modpath%\release\mods\mod0000_sharedutilsmappinsfhudpatch\" /e /s /y

:: then the dlcs
mkdir "%modpath%\release\dlc\"
XCOPY "%modpath%\shared-utils\packed\" "%modpath%\release\dlc\dlcsharedutils\" /e /s /y