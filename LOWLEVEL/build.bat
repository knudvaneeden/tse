@echo off
setlocal
set BCC=G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC55\bin
set TDUMP=G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC102\bin\tdump.exe
set PATH=%BCC%;%PATH%

if exist lowlevel.obj del lowlevel.obj
if exist lowlevel.dll del lowlevel.dll
if exist lowlevel.tds del lowlevel.tds

bcc32 -c -O2 -w lowlevel.cpp
if errorlevel 1 goto error

ilink32 -Tpd -aa -x -c c0d32.obj lowlevel.obj, lowlevel.dll,, import32.lib cw32.lib, lowlevel.def
if errorlevel 1 goto error

echo.
echo Built lowlevel.dll successfully.
if not exist "%TDUMP%" goto no_tdump
%TDUMP% -ee lowlevel.dll
goto done

:no_tdump
echo.
echo WARNING: tdump.exe was not found at:
echo %TDUMP%
echo Skipping export verification.
goto done

:error
echo.
echo ERROR: lowlevel.dll was not built.
endlocal
goto :eof

:done
endlocal
