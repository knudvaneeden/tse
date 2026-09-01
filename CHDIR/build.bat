@echo off
setlocal

rem CHDIRDLL build for Borland C++ 5.5/5.5.1 command-line tools.
rem Version: 1.0.0.0.1

if exist chdirdll.dll del chdirdll.dll
if exist chdirdll.obj del chdirdll.obj
if exist chdirdll.lib del chdirdll.lib
if exist chdirdll.tds del chdirdll.tds

bcc32 -c -O2 -w -tWD chdirdll.c
if errorlevel 1 goto build_error

ilink32 -Tpd -aa -c c0d32.obj chdirdll.obj, chdirdll.dll,, import32.lib cw32.lib, chdirdll.def
if errorlevel 1 goto build_error

echo.
echo Build completed: chdirdll.dll
goto end

:build_error
echo.
echo Build failed.
exit /b 1

:end
endlocal

