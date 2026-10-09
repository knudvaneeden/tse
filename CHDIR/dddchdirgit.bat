 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 00:04:00]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CHDIR\
 git add chdir.txt
 git add chdir.zip
 git add chdir.dll
 git add chdir_readme.md
 git add build.bat
 git add chdir.s
 git add chdirdll.c
 git add chdirdll.def
 git add chdirdll.dll
 git commit -m "Update chdir directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CHDIR
