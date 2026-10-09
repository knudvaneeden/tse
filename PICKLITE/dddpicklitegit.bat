 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 19:22:04]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PICKLITE\
 git add 01.png
 git add picklite.ini
 git add picklite.s
 git add picklite.zip
 git add picklite1.0.0.0.17.zip
 git add picklite_readme.md
 git commit -m "Update picklite directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PICKLITE
