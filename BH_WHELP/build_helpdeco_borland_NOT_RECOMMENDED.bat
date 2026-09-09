@echo off
rem Diagnostic only. The Borland-built HelpDeco stopped in TopicDump at topic 1253
rem for the supplied win32.hlp. Normal users should retain the supplied GCC-built
rem 32-bit helpdeco.exe and run build.bat instead.
bcc32 -Od -ehelpdeco_borland.exe helpdeco.c helpdec1.c
