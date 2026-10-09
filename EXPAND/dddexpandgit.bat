 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 01:20:32]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EXPAND\
 git add expand.s
 git add expand.zip
 git add expand_readme.md
 git commit -m "Update expand directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EXPAND
