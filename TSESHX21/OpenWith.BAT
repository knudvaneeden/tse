@echo off

rem ************************************************************************
rem *                                                                      *
rem *   OpenWith.Bat                                                       *
rem *                                                                      *
rem *   Install "Open With TSE" shell extensions.                          *
rem *                                                                      *
rem *   Version         v2.10/09.07.99                                     *
rem *   Copyright       (c) 1997-99 by DiK                                 *
rem *                                                                      *
rem ************************************************************************

echo TSE Shell Extensions 2.1 (c) 1997-99 by DiK
echo.

call sc32 openwith
if errorlevel 1 goto :error
set CalledFromBatch=YES
call e32 -eopenwith
set CalledFromBatch=
goto :done

:error
cls
echo TSE Shell Extensions 2.1 (c) 1997-99 by DiK
echo.
echo ERROR: need TSE v2.8 or later to compile and run
echo.

:done

