@echo off
setlocal

set BCCBIN=g:\language\computer\cpp\embarcadero\borland\bcc55\bin
set BCCLIB=g:\language\computer\cpp\embarcadero\borland\bcc55\lib

"%BCCBIN%\bcc32.exe" -c -O2 -tWD -w- fl32.c
if errorlevel 1 goto error

"%BCCBIN%\ilink32.exe" -Tpd -aa "%BCCLIB%\c0d32.obj" fl32.obj, fl32.dll,, "%BCCLIB%\import32.lib" "%BCCLIB%\cw32.lib", fl32.def
if errorlevel 1 goto error

echo Built fl32.dll successfully.
goto end

:error
echo Build failed.

:end
endlocal
