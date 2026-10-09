 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 13:47:31]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GETWORD3\
 git add getword3.s
 git add getword3.zip
 git add getword3_readme.md
 git commit -m "Update getword3 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GETWORD3
