 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 13:51:04]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MFFND58\

 git add 01.png
 git add make_mff.bat
 git add mffind.inc
 git add mffind.ini
 git add mffind.s
 git add mffind2.inc
 git add mffind2.s
 git add mffind3.s
 git add mffind4.s
 git add mffind5.s
 git add mffind6.s
 git add mffnd58.ini
 git add mffnd58.zip
 git add mffnd581.0.0.0.2.zip
 git add mffnd58_readme.md
 git commit -m "Update mffnd58 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MFFND58
