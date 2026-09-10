@echo off
setlocal
cd /d "%~dp0"

echo Building GREP3230 portable package...
echo.

echo [1/5] Compiling dialogp.s...
sc32 dialogp.s
if errorlevel 1 goto build_failed

echo.
echo [2/5] Compiling dialog.s...
sc32 dialog.s
if errorlevel 1 goto build_failed

echo.
echo [3/5] Compiling GETHELP.SI...
sc32 GETHELP.SI
if errorlevel 1 goto build_failed

echo.
echo [4/5] Compiling HELPHELP.S...
sc32 HELPHELP.S
if errorlevel 1 goto build_failed

echo.
echo [5/5] Compiling grep.s...
sc32 grep.s
if errorlevel 1 goto build_failed

echo.
echo Build completed successfully.
echo Created: dialogp.mac, dialog.mac, GETHELP.mac, HELPHELP.mac, grep.mac
goto build_done

:build_failed
echo.
echo BUILD FAILED. Review the compiler error shown above.
exit /b 1

:build_done
endlocal
exit /b 0
