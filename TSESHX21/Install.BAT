@echo off

rem ************************************************************************
rem *                                                                      *
rem *   Install.Bat                                                        *
rem *                                                                      *
rem *   Install windows shell extensions for TSE.                          *
rem *                                                                      *
rem *   Version         v2.00/15.04.99                                     *
rem *   Copyright       (c) 1997-99 by DiK                                 *
rem *                                                                      *
rem ************************************************************************

echo TSE Shell Extensions 2.0 (c) 1997-99 by DiK
echo.

call sc32 install
if errorlevel 1 goto :error
set CalledFromBatch=YES
call e32 -einstall
set CalledFromBatch=
goto :done

:error
cls
echo TSE Shell Extensions 2.0 (c) 1997-99 by DiK
echo.
echo ERROR: need TSE v2.8 or later to compile and run
echo.

:done

