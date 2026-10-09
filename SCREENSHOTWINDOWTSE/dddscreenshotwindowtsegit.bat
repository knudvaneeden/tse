 @REM version: 1.0.0.0.0 [kn, ri, su, 20-09-2026 08:37:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SCREENSHOTWINDOWTSE\
 git commit -m "Update screenshotwindowtse directory files"
 git add 01.png
 git add build.bat
 git add screenshotwindowtse.dll
 git add screenshotwindowtse.ini
 git add screenshotwindowtse.s
 git add screenshotwindowtse1.0.0.0.18.zip
 git add screenshotwindowtse_dll.c
 git add screenshotwindowtse_readme.md
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SCREENSHOTWINDOWTSE
