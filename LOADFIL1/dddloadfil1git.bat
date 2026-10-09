 @REM version: 1.0.0.0.0 [kn, ri, we, 16-09-2026 14:43:28]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LOADFIL1\
 git add build.bat
 git add loadfil1.def
 git add loadfil1.dll
 git add loadfil1.zip
 git add loadfil1_1.0.0.0.5.zip
 git add loadfil1_dll.c
 git add loadfil1_readme.md
 git add loadfile.s
 git commit -m "Update loadfil1 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LOADFIL1
