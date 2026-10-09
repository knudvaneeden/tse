 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 14:48:54]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MLTTAB\
 git add 01.png
 git add mlttab.ini
 git add mlttab.zip
 git add mlttab1.0.0.0.2.zip
 git add mlttab_readme.md
 git add multitab.s
 git commit -m "Update mlttab directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MLTTAB
