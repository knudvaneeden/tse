@echo off
rem set EDIR=C:\TSEPRO
set EDIR=C:\TSEPRO
if exist "%EDIR%\sc32.exe" goto :OK
echo Unable to locate sc32.exe. Edit the SET command on the second line of
echo this batch file to reflect the editor's install directory. Do not use
echo a trailing backslash or quotes. Example:
echo set EDIR=D:\Program Files\TSE
goto :END

:OK
if not exist WORDSTAR.UI goto NO_WS
rem  *********************************************************************
rem  Use quotes in case the editor directory contains spaces; also, adding
rem  "\." to the path "helps" sc32 -s find the correct directory. I use -s
rem  instead of -b so it will work for e32 and g32 if they are in the same
rem  directory.
rem  *********************************************************************
"%EDIR%\sc32" "-s%EDIR%\." WORDSTAR.UI
goto :END

:NO_WS
echo Can't find WORDSTAR.UI.
goto :END

:END
set EDIR=
echo.
