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
echo Copy both DLL files, zip_nested.ps1, and filefin2.ini to the same directory.
echo Archive searching supports ZIP, JAR, TAR, TGZ, RAR, 7Z, and mixed nesting.
echo Configure 7z.exe and rar.exe paths in filefin2.ini when needed.
echo Make sure TSE Pro can load the DLL files from that directory.
goto end

:build_error
echo.
echo Build failed. Review the Borland compiler or linker messages above.
goto end

:end
endlocal
