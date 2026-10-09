 @REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 22:14:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\BULLET\
 git add bullet.s
 git add bullet_readme.md
 git add bullet.txt
 git add bullet.zip
 git add autowrap.s
 git commit -m "Update bullet directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/BULLET
