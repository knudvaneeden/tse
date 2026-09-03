@echo off
rem File    : build.bat
rem Version : 1.0.0.0.4
rem Date    : 2026-09-03

setlocal

if not exist cursorfix.c (
    echo Error: run BUILD.BAT from the directory containing cursorfix.c.
    goto build_end
)

bcc32 -c -O2 -tWD -w- cursorfix.c
if errorlevel 1 goto build_error

ilink32 -Tpd -aa c0d32.obj cursorfix.obj, cursorfix.dll,,import32.lib cw32.lib,cursorfix.def,
if errorlevel 1 goto build_error

echo.
echo Build completed: cursorfix.dll
goto build_end

:build_error
echo.
echo Build failed.

:build_end
endlocal
