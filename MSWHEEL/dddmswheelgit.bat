 @REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 12:13:17]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MSWHEEL\
 git add mswheel.dll
 git add mswheel.ini
 git add mswheel.s
 git add mswheel.zip
 git add mswheel1.0.0.0.0.zip
 git add mswheel_readme.md
 git commit -m "Update mswheel directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MSWHEEL
