 @REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 22:30:34]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\BULLET11\
 git add bullet.s
 git add bullet.txt
 git add bullet11_readme.md
 git add bullet11.zip
 git add autowrap.s
 git add bullet11(2).zip
 git add ini.s
 git add ini.si
 git add ini.txt
 git commit -m "Update bullet11 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/BULLET11
