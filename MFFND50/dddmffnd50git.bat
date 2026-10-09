 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 13:27:46]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MFFND50\
 git add 01.png
 git add english.zip
 git add german.zip
 git add mffind.ini
 git add mffind.s
 git add mffnd50.ini
 git add mffnd50.zip
 git add mffnd501.0.0.0.1.zip
 git add mffnd50_readme.md
 git commit -m "Update mffnd50 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MFFND50
