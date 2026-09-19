 @REM version: 1.0.0.0.0 [kn, ri, sa, 19-09-2026 22:47:17]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LOWLEVEL\
 git add 01.png
 git add build.bat
 git add dddlowlevelgit.bat
 git add lowlevel(1).inc
 git add lowlevel.cpp
 git add lowlevel.def
 git add lowlevel.dll
 git add lowlevel.inc
 git add lowlevel.ini
 git add lowlevel.s
 git add lowlevel.zip
 git add lowlevel_demo.s
 git add lowlevel_readme.md
 git add lowlevel1.0.0.0.4.zip
 git commit -m "Update lowlevel directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LOWLEVEL
