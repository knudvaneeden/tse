 @REM version: 1.0.0.0.0 [kn, ri, mo, 14-09-2026 19:04:54]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\KEYWS02\
 git add autoscan.key
 git add country.key
 git add keyws.dat
 git add keyws.key
 git add keyws.s
 git add keyws02.zip
 git add maincat.key
 git add keyws02_readme.md
 git commit -m "Update keyws02 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/KEYWS02
