 @REM version: 1.0.0.0.0 [kn, ri, we, 30-09-2026 02:03:13]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MOVEMENTCURSOR01\

 git add 01.gif
 git add movementcursor01.ini
 git add movementcursor01.s
 git add movementcursor011.0.0.0.0.zip
 git add movementcursor01_readme.md
 git commit -m "Update movementcursor01 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MOVEMENTCURSOR01
