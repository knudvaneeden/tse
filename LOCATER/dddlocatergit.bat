 @REM version: 1.0.0.0.0 [kn, ri, sa, 19-09-2026 01:01:43]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LOCATER\
 git add locater.ini
 git add locater.zip
 git add locater1.0.0.0.0.zip
 git add locater_readme.md
 git add locnear.s
 git add locnxtto.s
 git commit -m "Update locater directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LOCATER
