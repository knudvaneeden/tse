 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 00:53:27]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HSKRO100\
 git add build.bat
 git add hskro100.c
 git add hskro100.def
 git add hskro100.dll
 git add hskro100.zip
 git add hskro100_readme.md
 git add readhlpr.inc
 git add readlist.inc
 git add readmenu.inc
 git add readmsg.inc
 git add readonly.map
 git add readonly.s
 git add readstat.inc
 git commit -m "Update hskro100 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HSKRO100
