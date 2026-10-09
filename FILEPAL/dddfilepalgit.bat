 @REM version: 1.0.0.0.0 [kn, ri, tu, 08-09-2026 17:38:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FILEPAL\
 git add filepal.dat
 git add filepal.s
 git add filepal.zip
 git add filepal_readme.md
 git commit -m "Update filepal directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FILEPAL
