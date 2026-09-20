@echo off
setlocal

set BCC55=g:\language\computer\cpp\embarcadero\borland\bcc55

if not exist "%BCC55%\bin\bcc32.exe" (
    echo ERROR: bcc32.exe not found at:
    echo "%BCC55%\bin\bcc32.exe"
    exit /b 1
)

echo Building screenshotwindowtse.dll ...
"%BCC55%\bin\bcc32.exe" -tWD -O2 -u- -I"%BCC55%\include" -L"%BCC55%\lib" -escreenshotwindowtse.dll screenshotwindowtse_dll.c
if errorlevel 1 exit /b 1

echo.
echo Compiling screenshotwindowtse.s ...
sc32 screenshotwindowtse.s
if errorlevel 1 exit /b 1

echo.
echo Build completed:
echo   screenshotwindowtse.dll
echo   screenshotwindowtse.mac
endlocal
