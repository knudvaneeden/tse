 @REM version: 1.0.0.0.0 [kn, ri, we, 09-09-2026 16:39:29]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FL\
 git add build.bat
 git add fl.s
 git add fl.zip
 git add fl32.c
 git add fl32.def
 git add fl32.dll
 git add fl_readme.md
 git add fl_windows_dll_1.0.0.0.12.zip
 git commit -m "Update fl directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FL
