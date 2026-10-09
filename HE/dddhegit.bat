 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 23:31:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HE\
 git add he.zip
 git add hexedit.s
 git add he_readme.md
 git commit -m "Update he directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HE
