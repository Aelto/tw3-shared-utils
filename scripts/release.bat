call variables.cmd

set releasemods=%modpath%\release\mods
set bundleddir=%modpath%\release.bundled
set bundledmod=%bundleddir%\mods\modZZZsharedutils
set localpath=content\scripts\local\sharedutils
set bundledout=%bundledmod%\%localpath%

rmdir "%modpath%\release" /s /q
rmdir "%bundleddir%\" /s /q

mkdir "%modpath%\release"
mkdir "%bundledout%"

mkdir %releasemods%
call :movetorelease mod_sharedutils_custombossbar false
call :movetorelease mod_sharedutils_customcooldowns false
call :movetorelease mod_sharedutils_damagemodifiers true
call :movetorelease mod_sharedutils_dialogChoices true
call :movetorelease mod_sharedutils_dialogHover true
call :movetorelease mod_sharedutils_helpers true
call :movetorelease mod_sharedutils_mappins true
call :movetorelease mod_sharedutils_noticeboards true
call :movetorelease mod_sharedutils_npcInteraction true
call :movetorelease mod_sharedutils_oneliners true 
call :movetorelease mod_sharedutils_glossary true
call :movetorelease mod_sharedutils_menudescriptors true

:: copy the bundled release into the redkit workspace
:: not needed anymore as we can compile a bundle directly using wcc_lite
::
:: set workspacescripts=%modpath%\redkit\sharedutils\workspace\scripts\local
:: rmdir %workspacescripts% /s /q
:: XCOPY "%bundledout%\" "%workspacescripts%\" /e /s /y

call compileblob.bat

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::FUNCTIONS::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
goto:eof

:: moves the provided module to the normal release
::
:: the second parameters defines whether it should also be added to the bundled
:: release, which is a single mod folder with all local files in the same place
:movetorelease
  XCOPY "%modpath%\%~1\" "%releasemods%\%~1\" /e /s /y

  set shouldmovetobundled=%~2
  if "%shouldmovetobundled%" == "true" (
    call :movetobundled %~1
  )
goto:eof


:: moves the provided module to the bundled release
:movetobundled
  echo Moving %~1 to bundled release
  ::echo "%releasemods%\%~1\%localpath%"
  ::echo "%bundledout%"
  XCOPY "%releasemods%\%~1\%localpath%\" "%bundledout%"  /e /s /y
goto:eof