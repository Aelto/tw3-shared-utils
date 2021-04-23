:: bundles the files from /modRandomEncountersReworked for the DLC

@echo off

call variables.cmd

cd %modkitpath%

rmdir "%modpath%\shared-utils\packed\content\" /s /q
mkdir "%modpath%\shared-utils\packed\content\"

call wcc_lite.exe pack -dir=%modpath%\shared-utils\files\mod\cooked\ -outdir=%modpath%\shared-utils\packed\content\
call wcc_lite.exe metadatastore -path=%modpath%\shared-utils\packed\content\

cd %modpath%\scripts