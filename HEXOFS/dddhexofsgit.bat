 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 23:49:49]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HEXOFS\
 git add hexofs.s
 git add hexofs.zip
 git add hexofs_readme.md
 git commit -m "Update hexofs directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HEXOFS
