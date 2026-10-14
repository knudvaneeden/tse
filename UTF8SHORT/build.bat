@echo off
rem UTF8SHORT 1.0.0.0.4 - OpenAI Codex (GPT-6)
rem Test: build.bat "F:\WORDPROC\tse32_v45024\sc32.exe"
rem %1 = optional SAL compiler. No parameter builds the DLL only.
rem Run directly in TCC or CMD. No nested TCC invocation.

setlocal

rem PART 1 - USER SETTINGS
set "BCCROOT=G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC55"
set "SALCOMPILER=%~1"

rem PART 2 - STABLE LOGIC
pushd "%~dp0"
set "PATH=%BCCROOT%\Bin;%PATH%"
set "BUILDRESULT=1"
echo UTF8SHORT version 1.0.0.0.4
if not exist "%BCCROOT%\Bin\bcc32.exe" goto no_compiler
if not exist "%BCCROOT%\Bin\ilink32.exe" goto no_compiler
if not exist "utf8short.c" goto no_sources
if not exist "utf8short.def" goto no_sources
"%BCCROOT%\Bin\bcc32.exe" -c -O2 -w -tWD -I"%BCCROOT%\Include" utf8short.c
if errorlevel 1 goto failed
"%BCCROOT%\Bin\ilink32.exe" -Tpd -aa -x -L"%BCCROOT%\Lib" c0d32.obj utf8short.obj,utf8short.dll,,import32.lib cw32.lib,utf8short.def
if errorlevel 1 goto failed
echo Built 32-bit utf8short.dll.
if "%SALCOMPILER%" == "" goto success
"%SALCOMPILER%" utf8short.s
if errorlevel 1 goto failed
"%SALCOMPILER%" utf8short_run.s
if errorlevel 1 goto failed
echo Built utf8short.mac and utf8short_run.mac.
:success
set "BUILDRESULT=0"
goto done
:no_compiler
echo Edit BCCROOT in PART 1 to locate Borland C++ 5.5.1.
goto done
:no_sources
echo Keep build.bat beside utf8short.c and utf8short.def in the extracted package.
goto done
:failed
echo Build failed. See diagnostics above.
:done
echo Build exit code: %BUILDRESULT%
pause
popd
endlocal & exit /b %BUILDRESULT%
