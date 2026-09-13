@echo off
setlocal

rem SPEAK.DLL for Borland C++ 5.5.1
rem Version 1.0.0.0.0 - 2026-09-13

set "BCC_ROOT=G:\language\computer\cpp\embarcadero\borland\bcc55"
set "BCC_BIN=%BCC_ROOT%\bin"
set "BCC_LIB=%BCC_ROOT%\lib"
set "BCC_INCLUDE=%BCC_ROOT%\include"

if not exist "%BCC_BIN%\bcc32.exe" (
  echo ERROR: Cannot find %BCC_BIN%\bcc32.exe
  exit /b 1
)

if not exist speak_bcc55.cpp (
  echo ERROR: Run build.bat in the directory containing speak_bcc55.cpp.
  exit /b 1
)

if not exist speak.def (
  echo ERROR: speak.def is missing.
  exit /b 1
)

del speak_bcc55.obj 2>nul
del speak.dll 2>nul
del speak.map 2>nul

"%BCC_BIN%\bcc32.exe" -c -O2 -tWD -WM -w- -I"%BCC_INCLUDE%" speak_bcc55.cpp
if errorlevel 1 goto failed

"%BCC_BIN%\ilink32.exe" -Tpd -aa -x -L"%BCC_LIB%" ^
  c0d32.obj speak_bcc55.obj, speak.dll, speak.map, ^
  import32.lib cw32mt.lib, speak.def
if errorlevel 1 goto failed

if not exist speak.dll goto failed

echo.
echo Built speak.dll successfully.
exit /b 0

:failed
echo.
echo Build failed.
exit /b 1
