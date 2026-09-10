@echo off
rem GREP1621 portable package build 1.0.0.0.2
rem Rebuild every required macro for the installed TSE SAL version.

echo.
echo Compiling dialogp.s ...
sc32 dialogp.s
if errorlevel 1 goto failed

echo.
echo Compiling dialog.s ...
sc32 dialog.s
if errorlevel 1 goto failed

echo.
echo Compiling gethelp.si ...
sc32 gethelp.si
if errorlevel 1 goto failed

echo.
echo Compiling helphelp.s ...
sc32 helphelp.s
if errorlevel 1 goto failed

echo.
echo Compiling grep.s ...
sc32 grep.s
if errorlevel 1 goto failed

echo.
echo Build completed: DIALOGP.MAC, DIALOG.MAC, GETHELP.MAC,
echo HELPHELP.MAC, and GREP.MAC.
goto done

:failed
echo.
echo Build failed. Correct the compiler error shown above.

:done
