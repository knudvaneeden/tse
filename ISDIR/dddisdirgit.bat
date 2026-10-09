 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 20:27:08]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\ISDIR\
 git add build.bat
 git add isdir.c
 git add isdir.def
 git add isdir.dll
 git add isdir.inc
 git add isdir.s
 git add isdir.zip
 git add isdir_dll_1.0.0.0.2.zip
 git add isdir_readme.md
 git commit -m "Update isdir directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/ISDIR
