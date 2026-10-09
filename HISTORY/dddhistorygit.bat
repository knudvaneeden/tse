 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 00:19:24]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HISTORY\
 git add history.s
 git add history.zip
 git add historym.dat
 git add historymove.s
 git add history_readme.md
 git commit -m "Update history directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HISTORY
