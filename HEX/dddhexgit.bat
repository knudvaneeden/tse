 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 23:38:34]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HEX\
 git add hex.s
 git add hex.zip
 git add hex_readme.md
 git commit -m "Update hex directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HEX
