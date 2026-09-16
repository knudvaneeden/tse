@echo off
rem LOADFIL1 1.0.0.0.5 - Borland C++ 5.5.1 / TSE SAL build
set BCC55=g:\language\computer\cpp\embarcadero\borland\bcc55

if not exist "%BCC55%\bin\bcc32.exe" goto no_bcc

"%BCC55%\bin\bcc32.exe" -c -O2 -tWD -I"%BCC55%\include" loadfil1_dll.c
if errorlevel 1 goto failed

"%BCC55%\bin\ilink32.exe" -Tpd -aa -L"%BCC55%\lib" c0d32.obj loadfil1_dll.obj, loadfil1.dll,, import32.lib cw32.lib, loadfil1.def
if errorlevel 1 goto failed

sc32 loadfile.s
if errorlevel 1 goto failed

echo.
echo LOADFIL1.DLL and LOADFILE.MAC were built successfully.
goto end

:no_bcc
echo Borland C++ 5.5.1 was not found at:
echo %BCC55%
goto end

:failed
echo.
echo Build failed.

:end
set BCC55=
