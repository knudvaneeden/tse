 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 19:38:42]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MOVE_1\
 git add 01.png
 git add movement.s
 git add move_1.ini
 git add move_1.zip
 git add move_11.0.0.0.2.zip
 git add move_1_readme.md
 git commit -m "Update move_1 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MOVE_1
