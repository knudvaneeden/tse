@echo off
setlocal

if exist invaders32.obj del invaders32.obj
if exist invaders32.dll del invaders32.dll

bcc32 -c -O2 -tWD invaders32.c
if errorlevel 1 goto error

ilink32 -Tpd -aa -c c0d32.obj invaders32.obj,invaders32.dll,,import32.lib cw32.lib,invaders32.def
if errorlevel 1 goto error

sc32 invaders.s
if errorlevel 1 goto error

echo.
echo Build completed: invaders32.dll and invaders.mac
goto end

:error
echo.
echo Build failed.
exit /b 1

:end
endlocal
