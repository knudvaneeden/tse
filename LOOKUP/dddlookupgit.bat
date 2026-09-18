 @REM version: 1.0.0.0.0 [kn, ri, sa, 19-09-2026 01:21:32]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LOOKUP\
 git add lookup.s
 git add lookup.zip
 git add lookup1.0.0.0.3.zip
 git add tse.260
 git add dddlookupgit.bat
 git add lookup.ini
 git commit -m "Update lookup directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LOOKUP
