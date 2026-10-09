 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 00:21:15]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DIRLIST\
 git add dirlist.s
 git add dirlist.zip
 git add dirlist_readme.md
 git commit -m "Update dirlist directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DIRLIST
