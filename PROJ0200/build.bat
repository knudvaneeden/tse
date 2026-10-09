@echo off
@REM Run this batch file from the extracted package's main directory.
@REM Usage: build.bat "F:\WORDPROC\tse32_v45024\sc32.exe"
@REM Use the sc32.exe matching your TSE installation.
if "%1"=="" goto usage
SET sc32=%1

cd src
cd mac

%sc32% proj.si
if errorlevel 1 goto compile_failed
%sc32% pjfile.si
if errorlevel 1 goto compile_failed
%sc32% gethelp.si
if errorlevel 1 goto compile_failed
%sc32% helphelp.s
if errorlevel 1 goto compile_failed
%sc32% projstart.s
if errorlevel 1 goto compile_failed
%sc32% projsession.s
if errorlevel 1 goto compile_failed
%sc32% projtransfer.s
if errorlevel 1 goto compile_failed
%sc32% projsvnbrowse.s
if errorlevel 1 goto compile_failed
%sc32% git.s
if errorlevel 1 goto compile_failed

@REM Return from SRC\MAC to the directory containing this batch file.
cd ..
cd ..

copy SRC\MAC\proj.si
copy SRC\MAC\proj.mac
copy SRC\MAC\pjfile.si
copy SRC\MAC\pjfile.mac
copy SRC\MAC\gethelp.si
copy SRC\MAC\gethelp.mac
copy SRC\MAC\helphelp.s
copy SRC\MAC\helphelp.mac
copy SRC\MAC\projstart.s
copy SRC\MAC\projstart.mac
copy SRC\MAC\projsession.s
copy SRC\MAC\projsession.mac
copy SRC\MAC\projtransfer.s
copy SRC\MAC\projtransfer.mac
copy SRC\MAC\projsvnbrowse.s
copy SRC\MAC\projsvnbrowse.mac
copy SRC\MAC\git.s
copy SRC\MAC\git.mac
copy SRC\MAC\proj.hlp
goto done

:compile_failed
cd ..
cd ..
echo SAL compilation failed; no macros were copied.
goto done

:usage
echo Usage: build.bat "C:\path to TSE\sc32.exe"
:done
