 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 13:17:15]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GETDATE\
 git add getdate.s
 git add getdate.zip
 git add getdate_readme.md
 git commit -m "Update getdate directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GETDATE
