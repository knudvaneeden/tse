 @REM version: 1.0.0.0.0 [kn, ri, mo, 14-09-2026 21:25:50]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LISTLOAD\
 git add listload.s
 git add listload.zip
 git add listload_readme.md
 git commit -m "Update listload directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LISTLOAD
