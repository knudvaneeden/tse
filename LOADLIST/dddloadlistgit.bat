 @REM version: 1.0.0.0.0 [kn, ri, fr, 18-09-2026 23:02:35]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LOADLIST\
 git add loadlist.ini
 git add loadlist.s
 git add loadlist.zip
 git add loadlist1.0.0.0.0p.zip
 git add loadlist_readme.md
 git commit -m "Update loadlist directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LOADLIST
