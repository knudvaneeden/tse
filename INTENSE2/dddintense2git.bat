 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 18:36:50]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\INTENSE2\
 git add build.bat
 git add colors.def
 git add colors.dll
 git add colors.s
 git add colorsdll.c
 git add dddintense2git.bat
 git add intense2.zip
 git add intense2_demo.s
 git add intense2_dll_portable.zip
 git add intense2_readme.md
 git commit -m "Update intense2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/INTENSE2
