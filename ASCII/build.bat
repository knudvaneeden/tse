@echo off
rem ASCII chart DLL build script, version 1.0.0.0.4
rem Run from a Borland C++ 5.5 command prompt.

setlocal
pushd "%~dp0"
if exist asciidll.dll del /q asciidll.dll
if exist asciidll.obj del /q asciidll.obj

bcc32 -c -O2 -tWD -w- asciidll.c
if errorlevel 1 goto build_error

ilink32 -Tpd -aa -c -x c0d32.obj asciidll.obj,asciidll.dll,,import32.lib cw32.lib,asciidll.def
if errorlevel 1 goto build_error

if not exist asciidll.dll goto build_error
echo.
echo Built asciidll.dll successfully.
goto done

:build_error
echo.
echo ERROR: asciidll.dll was not built.
popd
exit /b 1

:done
popd
endlocal
