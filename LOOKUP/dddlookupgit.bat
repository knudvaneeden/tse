 @REM version: 1.0.0.0.0 [kn, ri, sa, 19-09-2026 01:21:32]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LOOKUP\
 git add lookup.s
 git add lookup.zip
 git add lookup1.0.0.0.4.zip
 git add tse.260
 git add c.260
 git add cpp.260
 git add go.260
 git add java.260
 git add javascript.260
 git add python.260
 git add rust.260
 git add typescript.260
 git add lookup.ini
 git add 01.png
 git commit -m "Update lookup directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LOOKUP
