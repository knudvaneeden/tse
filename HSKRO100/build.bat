@echo off
setlocal

rem HSKRO100 Win32 build for Borland C++ 5.5/5.5.1 and TSE 4.50.
rem Version: 1.0.0.0.1
rem Run this batch file from the directory containing these files.

if exist hskro100.dll del hskro100.dll
if exist hskro100.obj del hskro100.obj
if exist hskro100.lib del hskro100.lib
if exist hskro100.tds del hskro100.tds
if exist readonly.mac del readonly.mac

bcc32 -c -O2 -w -tWD hskro100.c
if errorlevel 1 goto build_error

ilink32 -Tpd -aa -c c0d32.obj hskro100.obj, hskro100.dll,, import32.lib cw32.lib, hskro100.def
if errorlevel 1 goto build_error

sc32 readonly.s
if errorlevel 1 goto build_error

echo.
echo Build completed: hskro100.dll and readonly.mac
goto end

:build_error
echo.
echo Build failed.
exit /b 1

:end
endlocal
