:: copies the files from the repository into the game
:: it's an easy way to install it

@echo off

call variables.cmd

rem install scripts
rmdir "%gamePath%\mods\%modName%\content\scripts" /s /q

if "%1"=="-keep" (
  rmdir "%gamePath%\mods\mod_sharedutils_mappins\content\" /s /q
  rmdir "%gamePath%\mods\mod_sharedutils_dialogChoices\content\" /s /q
  rmdir "%gamePath%\mods\mod_sharedutils_journalquest\content\" /s /q
  rmdir "%gamePath%\mods\mod_sharedutils_npcInteraction\content\" /s /q
)

XCOPY "%modpath%\mod_sharedutils_mappins" "%gamePath%\mods\mod_sharedutils_mappins\"  /e /s /y
XCOPY "%modpath%\mod_sharedutils_dialogChoices" "%gamePath%\mods\mod_sharedutils_dialogChoices\"  /e /s /y
XCOPY "%modpath%\mod_sharedutils_journalquest" "%gamePath%\mods\mod_sharedutils_journalquest\"  /e /s /y
XCOPY "%modpath%\mod_sharedutils_npcInteraction" "%gamePath%\mods\mod_sharedutils_npcInteraction\"  /e /s /y
XCOPY "%modpath%\mod_sharedutils_noticeboards" "%gamePath%\mods\mod_sharedutils_noticeboards\"  /e /s /y

if "%1"=="-dlc" (
  echo "copying DLC"
  rmdir "%gamePath%\dlc\dlcsharedutils" /s /q
  xcopy "%modPath%\release\dlc" "%gamepath%\dlc" /e /s /y
)
