 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 18:12:32]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PICKFIL2\
 git add 01.png
 git add pickfil2.ini
 git add pickfil2.s
 git add pickfil2.zip
 git add pickfil21.0.0.0.0.zip
 git add pickfil2_readme.md
 git commit -m "Update pickfil2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PICKFIL2
