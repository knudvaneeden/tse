@echo off

rem     ----------------------------------------------------------------
rem
rem     Dialogs Install Utility
rem
rem     Version         v2.10/07.06.01
rem     Copyright       (c) 1996-2001 by DiK
rem
rem     Overview:
rem
rem     This batch file is meant as a tool to compile and install
rem     the dialogs package for TSE v2.5, v2.6, v2.8 and v3.0.
rem
rem     Usage:
rem
rem     Copy the source code to some tempory directory and run instdlg.
rem
rem     Command line format:
rem
rem     InstDlg  Editor_Version  [Target_Directory]
rem
rem     Editor_Version      25 or 26 or 28 or 30
rem     Target_Directory    TSE's macro directory (e.g. c:\tse\mac)
rem
rem     History
rem
rem     v2.10/07.06.01  adaption to version 2.10 of dialogs
rem                     added copying dlls
rem                     added version 3.0 switch
rem     v2.02/07.01.99  adaption to version 2.02 of dialogs
rem                     added new macros
rem                     added version 2.8 switch
rem     v2.01/02.04.97  no changes
rem     v2.00/24.10.96  first version
rem
rem     ----------------------------------------------------------------

rem     ----------------------------------------------------------------
rem     check command line arguments
rem     ----------------------------------------------------------------

if "%1" == "" goto :help
if not "%3" == "" goto :help

if %1 == 25 goto :inst25
if %1 == 26 goto :inst30
if %1 == 28 goto :inst30
if %1 == 30 goto :inst30

goto :help

rem     ----------------------------------------------------------------
rem     16-bit version
rem     ----------------------------------------------------------------

:inst25
if exist dc.s   call sc dc.s
if exist dd.s   call sc dd.s
if exist de.s   call sc de.s
call sc dialog.s
call sc dialogp.s
call sc dlgascii.s
call sc dlgbuff.s
call sc dlgcomp.s
call sc dlgcompx.s
call sc dlgfind.s
call sc dlgfnddo.s
call sc dlggoto.s
call sc dlghist.s
call sc dlgmcc.s
call sc dlgopen.s
call sc dlgrcnt.s
call sc dlgrplc.s
call sc dlgsetup.s
call sc dlgvideo.s
call sc drivelst.s
call sc setvideo.s
call sc inpbox.s
call sc msgbox.s
call sc dlgop16d.s
goto :install

rem     ----------------------------------------------------------------
rem     32-bit version
rem     ----------------------------------------------------------------

:inst30
if exist dc.s   call sc32 dc.s
if exist dd.s   call sc32 dd.s
if exist de.s   call sc32 de.s
call sc32 dialog.s
call sc32 dialogp.s
call sc32 dlgascii.s
call sc32 dlgbuff.s
call sc32 dlgcomp.s
call sc32 dlgcompx.s
call sc32 dlgfind.s
call sc32 dlgfnddo.s
call sc32 dlggoto.s
call sc32 dlghist.s
call sc32 dlgmcc.s
call sc32 dlgopen.s
call sc32 dlgrcnt.s
call sc32 dlgrplc.s
call sc32 dlgsetup.s
call sc32 dlgvideo.s
call sc32 drivelst.s
call sc32 setvideo.s
call sc32 inpbox.s
call sc32 msgbox.s

rem     ----------------------------------------------------------------
rem     move executables to macro folder
rem     ----------------------------------------------------------------

:install
if "%2" == "" goto :stop
if "%2" == "." goto :stop
move *.mac %2
if %1 == 25 goto :stop
copy *.dll %2
goto :stop

rem     ----------------------------------------------------------------
rem     help screen
rem     ----------------------------------------------------------------

:help
cls
echo.
echo Dialogs Install Utility
echo.
echo This batch file compiles and installs the dialogs macro package.
echo.
echo Command line format
echo.
echo InstDlg  Editor_Version  [Target_Directory]
echo.
echo Editor_Version      25 or 26 or 28 or 30
echo Target_Directory    TSE's macro directory (e.g. c:\tse\mac)
echo.
echo If you don't specify a target directory, the package is compiled only.
echo.

rem     ----------------------------------------------------------------
rem     common exit
rem     ----------------------------------------------------------------

:stop

