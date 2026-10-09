 @REM version: 1.0.0.0.0 [kn, ri, su, 06-09-2026 19:30:25]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GETFIDSO\
 git add getfidso.s
 git add getfidso_readme.md
 git add getfidso.zip
 git commit -m "Update getfidso.zip directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GETFIDSO
