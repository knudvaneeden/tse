@echo off
rem CAPSNUMS.DLL build script - version 1.0.0.0.3
rem Requires Borland C++ command-line compiler 5.5 in PATH.

bcc32 -c -O2 -w- capsnums.c
if errorlevel 1 goto build_failed

ilink32 -Tpd c0d32.obj capsnums.obj, capsnums.dll,, import32.lib cw32.lib, capsnums.def
if errorlevel 1 goto build_failed

echo.
echo Build completed: capsnums.dll
goto end

:build_failed
echo.
echo Build failed.
goto end

:end
