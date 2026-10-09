 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 12:20:59]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\ONLYONE\
 git add opentype.ini
 git add opentype.s
 git add opentype.zip
 git add opentype1.0.0.0.0.zip
 git add opentype_readme.md
 git commit -m "Update onlyone directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/ONLYONE
