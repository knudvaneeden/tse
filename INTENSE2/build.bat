@echo off
setlocal

if exist colorsdll.obj del colorsdll.obj
if exist colors.dll del colors.dll
if exist colors.lib del colors.lib

bcc32 -c -O2 -tWD colorsdll.c
if errorlevel 1 goto failed

ilink32 -Tpd -aa c0d32.obj colorsdll.obj, colors.dll, colors.map, import32.lib cw32.lib, colors.def
if errorlevel 1 goto failed

if not exist colors.dll goto failed
echo.
echo Build completed: colors.dll
goto done

:failed
echo.
echo Build failed.
exit /b 1

:done
endlocal

