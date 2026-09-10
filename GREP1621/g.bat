@echo off
if %@eval[2+2] == 4 goto 4dos

:dos
if "%1" == "" goto helpme
if "%1" == "?" goto helpme
if "%1" == "-?" goto helpme
if "%1" == "/?" goto helpme
e -egrep -v %1 %2 %3 %4 %5 %6 %7 %8 %9
goto end

:4dos
loadbtm on
if "%&" == "" goto helpme
if "%&" == "?" goto helpme
if "%&" == "-?" goto helpme
if "%&" == "/?" goto helpme
goto dogrep

:helpme
echo.
echo Usage:  G [-deilpwx] needle files
echo "needle" is the string to search for.
echo "files" is a list of filespecs, separated by spaces, commas, or semicolons.
echo.
echo Options:
echo   -d            search subDirectories
echo   -eFilespec    Exclude files matching "Filespec"
echo                 (separated by commas or semicolons, eg, "-e*.bak,*.tmp")
echo   -i            Ignore case
echo   -l            fiLenames only
echo   -pDir         start the search in Path "Dir"
echo                 (eg, "-pC:\")
echo   -w            whole Words only
echo   -x            regular eXpressions
echo.
echo (Note: long filenames are ok, as long as they don't contain spaces, commas,
echo or semicolons)
goto end

:dogrep
e -egrep -v %&

:end
