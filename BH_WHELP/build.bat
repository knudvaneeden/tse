@echo off
setlocal
set BCCBIN=g:\language\computer\cpp\embarcadero\borland\bcc55\bin
set PATH=%BCCBIN%;%PATH%

if not exist helpdeco.exe (
    echo Prebuilt 32-bit helpdeco.exe is missing.
    goto failed
)

bcc32 -O2 rtf2html.c
if errorlevel 1 goto failed
bcc32 -O2 hlp2html.c
if errorlevel 1 goto failed
bcc32 -O2 bh.c
if errorlevel 1 goto failed

echo Kept the supplied 32-bit helpdeco.exe.
echo Built rtf2html.exe, hlp2html.exe and bh.exe successfully.
goto end
:failed
echo Build failed.
exit /b 1
:end
endlocal
