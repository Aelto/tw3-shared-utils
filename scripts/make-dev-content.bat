::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Generates a scripts folder that contains both the vanilla content0 scripts
:: and the sharedutils scripts so you can use it as a base while developing
:: that depend on sharedutils.
::
:: The folder is generated from:
:: - the current installed version of Witcher 3
:: - the current release.bundled folder, `release.bat` can be used to refresh it
:: 
::
:: Depends on one ENV variable:
::   - WITCHER_ROOT, a path to a Witcher 3 install
set output=%cd%\..\dev-scripts
set gamescripts=%WITCHER_ROOT%\content\content0\scripts
set sharedutilsscripts=%cd%\..\release.bundled\mods\modZZZsharedutils\content\scripts

rmdir "%output%" /s /q
call :copygamescripts
call :copysharedutils


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::FUNCTIONS::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
goto:eof

:copygamescripts
  XCOPY "%gamescripts%\" "%output%\" /e /s /y
goto:eof


:copysharedutils
  XCOPY "%sharedutilsscripts%\" "%output%\" /e /s /y
goto:eof