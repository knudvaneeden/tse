 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 23:28:24]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COPYWORD\
 git add copyword.mac
 git add copyword.s
 git add copyword.zip
 git add copyword_readme.md
 git commit -m "Update copyword directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COPYWORD
