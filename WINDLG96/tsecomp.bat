@echo off

rem ************************************************************************
rem *                                                                      *
rem *   TseComp.Bat                                                        *
rem *                                                                      *
rem *   Start file comparison in batch mode                                *
rem *                                                                      *
rem *   Version         v3.03/29.07.99                                     *
rem *   Copyright       (c) 1994-99 by DiK                                 *
rem *                                                                      *
rem ************************************************************************

rem ************************************************************************
rem *   splash                                                             *
rem ************************************************************************

echo TSE File Comparison 3.0 (c) 1994-99 by DiK

rem ************************************************************************
rem *   check arguments                                                    *
rem ************************************************************************

if "%1" == "?" goto SYNTAX
if not "%3" == "" goto SYNTAX

if "%1" == "" goto START
if not exist %1 goto FILE1

if "%2" == "" goto START
if not exist %2 goto FILE2

rem ************************************************************************
rem *   start TSE and execute DlgComp                                      *
rem ************************************************************************

:START

set TSECOMPBATCHED=1
set TSECOMPCMDARG1=%1
set TSECOMPCMDARG2=%2

call e -edlgcomp

set TSECOMPBATCHED=
set TSECOMPCMDARG1=
set TSECOMPCMDARG2=

goto DONE

rem ************************************************************************
rem *   error messages                                                     *
rem ************************************************************************

:SYNTAX
echo.
echo Syntax:  TseComp  [First_File [Second_File]]
goto DONE

:FILE2
shift

:FILE1
echo.
echo File "%1" does not exist

rem ************************************************************************
rem *   the end                                                            *
rem ************************************************************************

:DONE
if not "%@eval[1+1]" == "2" echo.

