 @REM version: 1.0.0.0.0 [kn, ri, su, 06-09-2026 21:48:26]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GETFISCU\
 git add getfiscu.s
 git add getfiscu.zip
 git add getfiscu_readme.md
 git commit -m "Update getfiscu directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GETFISCU
