@echo off

set "pluginpath=%cd%"

pushd %~dp0
D:
cd D:\Dev\Openplanet\Tools
sign.exe --dir %pluginpath%
popd
