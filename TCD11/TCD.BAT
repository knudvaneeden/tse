@echo off
rem TCD.BAT 05/21/1993 05/26/1993
if .%1. == .. goto Help
echo %1>%MACPATH%tcd.tmp
%MACPATH%e.exe c:\tcd.dir -etcd
del %MACPATH%tcd.tmp
goto Alldone
:Help
cls
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³ Usage: TCD {directory}                  ³
echo ³                                         ³
echo ³ Note: DOS wildcard characters (* and ?) ³
echo ³       and TSE Regular Expressions are   ³
echo ³       supported                         ³
echo ³                                         ³
echo ³ Example: TCD *r?m*  ; finds c:\procomm  ³
echo ³          TCD e:*tse ; finds e:\tse      ³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pause
goto TheEnd
:Alldone
rem NOW, Execute a command
if .%2. == .. goto TheEnd
%2 %3 %4 %5 %6 %7 %8 %9
:TheEnd
