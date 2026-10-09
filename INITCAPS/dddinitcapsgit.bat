 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 17:26:19]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\INITCAPS\
 git add initcaps.s
 git add initcaps.inc
 git add initcaps.zip
 git add initcaps_readme.md
 git commit -m "Update initcaps directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/INITCAPS
