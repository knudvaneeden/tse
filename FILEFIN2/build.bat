@echo off
setlocal

rem FILEFIN2 DLL build for Borland C++ 5.5.1
rem Run from the directory containing this file.

bcc32 -tWD -O2 -u- -eff.dll ff_dll.c
if errorlevel 1 goto build_error

bcc32 -tWD -O2 -u- -ezip.dll zip_dll.c
if errorlevel 1 goto build_error

echo.
echo Build completed: ff.dll and zip.dll
echo Copy both DLL files and zip_nested.ps1 to the same directory.
echo Make sure TSE Pro can load the DLL files from that directory.
goto end

:build_error
echo.
echo Build failed. Review the Borland compiler or linker messages above.
goto end

:end
endlocal
