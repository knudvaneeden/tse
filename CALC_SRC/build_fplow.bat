@echo off
rem FPLOW.DLL build script version 1.0.0.0.7
rem Run from a Borland C++ 5.5 command prompt.

bcc32 -WD -O2 -w- -efplow.dll fplow.c
if errorlevel 1 goto failed

echo Built fplow.dll successfully.
goto end

:failed
echo FPLOW.DLL build failed.

:end
