@REM version: 1.0.0.0.0 [kn, ri, su, 27-09-2026 21:09:43]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\GIFANIM\
 git add 01.gif
 git add 02.gif
 git add gifanim.ini
 git add gifanim.ps1
 git add gifanim.s
 git add gifanim1.0.0.0.23.zip
 git add gifanim_readme.md
 git add _01.png
 git add _02.png
 git add _03.png
 git add _04.png
 git add _05.png
git commit -m "Update gifanim directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/GIFANIM
