@echo off
rem FINFO_32 Windows DLL build for Borland C++ 5.5.1
setlocal
bcc32 -c -O2 -tWD -w- finfo32.c
if errorlevel 1 goto error
ilink32 -Tpd -aa c0d32.obj finfo32.obj, finfo32.dll,, import32.lib cw32.lib, finfo32.def
if errorlevel 1 goto error
echo Built finfo32.dll successfully.
goto end
:error
echo Build failed.
:end
endlocal
