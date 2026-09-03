 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 18:44:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CURSORFIX\
 git add build.bat
 git add cursorfix.c
 git add cursorfix.def
 git add cursorfix.dll
 git add cursorfix.mac
 git add cursorfix.s
 git add cursorfix.zip
 git add cursorfix_readme.md
 git add dddcursorfixgit.bat
 git commit -m "Update cursorfix directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CURSORFIX
