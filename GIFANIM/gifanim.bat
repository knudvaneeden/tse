@echo off
rem GIFANIM 1.0.0.0.23 - run alongside gifanim.ps1 and gifanim_run.ini.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0gifanim.ps1" -IniFile "%~dp0gifanim_run.ini"
exit /b %ERRORLEVEL%
