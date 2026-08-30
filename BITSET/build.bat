@echo off
rem bitsetdll build script - version 1.0.0.0.5
rem If this file is in BCC55\bin, the compiler root is detected automatically.
rem Otherwise adjust the fallback BCCROOT path below.
rem Optional first argument: directory containing bitsetdll.s/bitsetdll.mac.
set "TSEMACRODIR=%~1"
if exist "%~dp0bcc32.exe" goto compiler_bin
set "BCCROOT=C:\Borland\BCC55"
goto compiler_ready

:compiler_bin
set "BCCROOT=%~dp0.."

:compiler_ready
set "PATH=%BCCROOT%\Bin;%PATH%"

bcc32 -c -O2 -w- -tWD -I"%BCCROOT%\Include" bitsetdll.cpp
if errorlevel 1 goto failed

ilink32 -Tpd -aa -x -L"%BCCROOT%\Lib" c0d32.obj bitsetdll.obj,bitsetdll.dll,,import32.lib cw32.lib,bitsetdll.def
if errorlevel 1 goto failed

echo Created bitsetdll.dll
if "%TSEMACRODIR%" == "" goto same_directory
if not exist "%TSEMACRODIR%\bitsetdll.s" goto bad_macro_directory
copy /y "bitsetdll.dll" "%TSEMACRODIR%\bitsetdll.dll" >nul
if errorlevel 1 goto copy_failed
echo Copied bitsetdll.dll to "%TSEMACRODIR%"
goto end

:same_directory
if exist "%~dp0bitsetdll.s" echo bitsetdll.dll is beside bitsetdll.s
goto end

:bad_macro_directory
echo DLL was built, but bitsetdll.s was not found in "%TSEMACRODIR%".
echo The DLL was not copied.
goto end

:copy_failed
echo DLL was built, but copying it to "%TSEMACRODIR%" failed.
goto end

:failed
echo Build failed.
goto end

:end
