 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 01:14:45]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FPOSASB4\
 git add fposasb4.s
 git add fposasb4.zip
 git add fposasb4_readme.md
 git commit -m "Update fposasb4 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FPOSASB4
