 @REM version: 1.0.0.0.0 [kn, ri, fr, 25-09-2026 01:40:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NEXTPUNC\
 git add nextpunc.ini
 git add nextpunc.s
 git add nextpunc.zip
 git add nextpunc1.0.0.0.0.zip
 git add nextpunc_readme.md
 git commit -m "Update nextpunc directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NEXTPUNC
