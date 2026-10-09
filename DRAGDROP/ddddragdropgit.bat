 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 15:53:41]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DRAGDROP\
 git add dragdrop.s
 git add dragdrop.zip
 git add dragdrop_readme.md
 git commit -m "Update dragdrop directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DRAGDROP
