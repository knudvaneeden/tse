 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 23:07:18]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COPYPART\
 git add copypart.s
 git add copypart.zip
 git add copypart_readme.md
 git commit -m "Update copypart directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COPYPART
