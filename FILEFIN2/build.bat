@echo off
setlocal

rem FILEFIN2 DLL build for Borland C++ 5.5.1
rem Version 1.0.0.0.49 - 2026-11-13 - OpenAI Codex
rem Run from the directory containing this file.

set "BCC32_EXE="
if exist "%CD%\bcc32.exe" set "BCC32_EXE=%CD%\bcc32.exe"
if not defined BCC32_EXE for %%I in (bcc32.exe) do set "BCC32_EXE=%%~$PATH:I"

if not defined BCC32_EXE goto compiler_not_found

for %%I in ("%BCC32_EXE%") do set "BCC_BIN=%%~dpI"
set "BCC_ROOT=%BCC_BIN%.."
set "BCC_INCLUDE=%BCC_ROOT%\include"
set "BCC_LIB=%BCC_ROOT%\lib"

if not exist "%BCC_INCLUDE%\windows.h" goto windows_header_not_found
if not exist "%BCC_LIB%" goto library_directory_not_found

echo Using compiler: "%BCC32_EXE%"
echo Using include:  "%BCC_INCLUDE%"
echo Using library:  "%BCC_LIB%"
echo.

"%BCC32_EXE%" -I"%BCC_INCLUDE%" -L"%BCC_LIB%" -tWD -O2 -u- -eff.dll ff_dll.c
if errorlevel 1 goto build_error

"%BCC32_EXE%" -I"%BCC_INCLUDE%" -L"%BCC_LIB%" -tWD -O2 -u- -ezip.dll zip_dll.c
if errorlevel 1 goto build_error

echo.
echo Build completed: ff.dll and zip.dll
echo Copy both DLL files, zip_nested.ps1, and filefin2.ini to the same directory.
echo Archive searching supports ZIP, JAR, TAR, TGZ, RAR, 7Z, and mixed nesting.
echo Configure 7z.exe and rar.exe paths in filefin2.ini when needed.
echo Make sure TSE Pro can load the DLL files from that directory.
goto end

:compiler_not_found
echo.
echo Build failed: bcc32.exe was not found in the current directory or PATH.
goto end

:windows_header_not_found
echo.
echo Build failed: "%BCC_INCLUDE%\windows.h" was not found.
echo The Borland C++ 5.5.1 Include directory is missing or incomplete.
goto end

:library_directory_not_found
echo.
echo Build failed: Borland library directory "%BCC_LIB%" was not found.
goto end

:build_error
echo.
echo Build failed. Review the Borland compiler or linker messages above.
goto end

:end
endlocal
