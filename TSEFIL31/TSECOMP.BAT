@echo off

rem ************************************************************************
rem *                                                                      *
rem *   TFSComp.BAT                                                        *
rem *                                                                      *
rem *   Start file compare in batch mode                                   *
rem *                                                                      *
rem *   Version         V2.00/28.04.95                                     *
rem *   Copyright       (c) 1994,95 by DiK                                 *
rem *                                                                      *
rem *   History                                                            *
rem *                                                                      *
rem *   V2.00/28.04.95  interface to TSEFile                               *
rem *                                                                      *
rem *   Remarks:                                                           *
rem *                                                                      *
rem *   The first filename in the editor command line ($ÿÿÿÿÿÿ$.$ÿ$)       *
rem *   includes the ascii character #255. This is a dirty trick, to       *
rem *   convince TSECompB.MAC that it has been executed by TSEComp.BAT.    *
rem *                                                                      *
rem ************************************************************************

rem ************************************************************************
rem *   splash                                                             *
rem ************************************************************************

echo.
echo TSE File Compare 2.1 (c) 1994,95 by DiK
echo.

rem ************************************************************************
rem *   checking arguments                                                 *
rem ************************************************************************

if "%1" == "" goto SYNTAX
if "%2" == "" goto SYNTAX
if not "%3" == "" goto SYNTAX

if not exist %1 goto FILE1
if not exist %2 goto FILE2

rem ************************************************************************
rem *   start TSE and execute TSEComp                                      *
rem ************************************************************************

e -etsecompb $ÿÿÿÿÿÿ$.$ÿ$ %1 %2
goto DONE

rem ************************************************************************
rem *   error messages                                                     *
rem ************************************************************************

:SYNTAX
echo Syntax:  TSEComp  Filename1  Filename2
goto DONE

:FILE1
echo File "%1" does not exist
goto DONE

:FILE2
echo File "%2" does not exist
goto DONE

rem ************************************************************************
rem *   the end                                                            *
rem ************************************************************************

:DONE
echo.

