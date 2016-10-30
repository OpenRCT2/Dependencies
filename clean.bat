@echo off

REM clean up main directory
git clean -fdX

REM clean up breakpad
pushd src\breakpad
SET DEPOT_TOOLS_UPDATE=0
CALL ..\depot_tools\gclient.bat revert -n
popd

REM clean up submodules
git submodule foreach "git clean -fdx && git checkout ."