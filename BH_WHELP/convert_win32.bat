@echo off
hlp2html.exe win32.hlp win32_html
if errorlevel 1 pause & exit /b 1
echo Edit bh.ini and set HelpFile to the full path of win32_html\win32.html
pause
