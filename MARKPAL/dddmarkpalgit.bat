 @REM version: 1.0.0.0.0 [kn, ri, mo, 21-09-2026 17:34:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MARKPAL\
 git add 01.png
 git add markpal.ini
 git add markpal.s
 git add markpal.zip
 git add markpal1.0.0.0.1.zip
 git add markpal_readme.md
 git commit -m "Update markpal directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MARKPAL
