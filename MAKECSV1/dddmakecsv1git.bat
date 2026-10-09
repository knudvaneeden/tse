 @REM version: 1.0.0.0.0 [kn, ri, mo, 21-09-2026 09:59:39]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MAKECSV1\
 git add makecsv.s
 git add makecsv.ini
 git add makecsv1.zip
 git add makecsv11.0.0.0.1.zip
 git add makecsv1_readme.md
 git add 01.png
 git commit -m "Update makecsv1 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MAKECSV1
