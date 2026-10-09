 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 23:46:21]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EDEBUG2\
 git add edebug.s
 git add edebug2.zip
 git add edebug2_readme.md
 git commit -m "Update edebug2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EDEBUG2
