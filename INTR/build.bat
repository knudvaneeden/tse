@echo off
setlocal

if exist intr32.obj del intr32.obj
if exist intr32.dll del intr32.dll
if exist intr32.lib del intr32.lib

bcc32 -c -O2 -tWD intr32.c
if errorlevel 1 goto build_error

ilink32 -Tpd -aa c0d32.obj intr32.obj, intr32.dll, intr32.map, import32.lib cw32.lib, intr32.def
if errorlevel 1 goto build_error

echo.
echo Build completed: intr32.dll
goto end

:build_error
echo.
echo Build failed.
exit /b 1

:end
endlocal

