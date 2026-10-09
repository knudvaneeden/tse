 @REM version: 1.0.0.0.0 [kn, ri, mo, 05-10-2026 13:47:41]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SUM\
 git add 01.png
 git add sum.ini
 git add sum.s
 git add sum1.0.0.0.1.zip
 git add sum_readme.md
 git commit -m "Update sum directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SUM
