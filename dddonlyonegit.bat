 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 12:20:59]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\ONLYONE\
 git add onlyone.s
 git add onlyone.zip
 git add onlyone.ini
 git add onlyone1.0.0.0.1.zip
 git commit -m "Update onlyone directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/ONLYONE
