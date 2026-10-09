 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 23:57:29]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CMTSE\
 git add cmtse.zip
 git add cmtse_readme.md
 git add created_with_tse.gif
 git add maintained_with_tse.gif
 git commit -m "Update cmtse directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CMTSE
