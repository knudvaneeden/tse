 @REM version: 1.0.0.0.0 [kn, ri, mo, 21-09-2026 23:48:31]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MATCH2\
 git add 01.png
 git add match2.ini
 git add match2.s
 git add match2.zip
 git add match21.0.0.0.13.zip
 git add match2_readme.md
 git commit -m "Update match2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MATCH2
