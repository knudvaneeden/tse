 @REM version: 1.0.0.0.0 [kn, ri, sa, 12-09-2026 15:33:04]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HISTREPAIR\
 git add histrepair.zip
 git add histrepair.s
 git add histrepair_readme.md
 git commit -m "Update histrepair directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HISTREPAIR
