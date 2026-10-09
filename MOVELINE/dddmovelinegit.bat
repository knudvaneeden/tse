 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 18:12:59]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MOVELINE\
 git add 01.png
 git add moveline.ini
 git add moveline.s
 git add moveline.zip
 git add moveline1.0.0.0.0.zip
 git add moveline_readme.md
 git commit -m "Update moveline directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MOVELINE
