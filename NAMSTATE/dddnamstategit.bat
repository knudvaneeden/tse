 @REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 22:39:16]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NAMSTATE\
 git add 01.png
 git add namstate.ini
 git add namstate.s
 git add namstate.si
 git add namstate.zip
 git add namstate1.0.0.0.1.zip
 git add namstate_readme.md
 git commit -m "Update namstate directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NAMSTATE
