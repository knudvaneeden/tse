 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 20:05:18]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\INVADERS\
 git add build.bat
 git add invaders.s
 git add invaders.zip
 git add invaders32.c
 git add invaders32.def
 git add invaders32.dll
 git add invaders_dll_1.0.0.0.5.zip
 git add invaders_readme.md
 git add ss32.h
 git commit -m "Update invaders directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/INVADERS
