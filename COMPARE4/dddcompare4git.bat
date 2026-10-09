 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 19:50:39]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COMPARE4\
 git add compare.s
 git add compare4.zip
 git add compare4_readme.md
 git commit -m "Update compare4 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COMPARE4
