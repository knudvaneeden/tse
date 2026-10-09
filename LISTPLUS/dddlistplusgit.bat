 @REM version: 1.0.0.0.0 [kn, ri, mo, 14-09-2026 22:12:13]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LISTPLUS\
 git add listplus.s
 git add listplus.zip
 git add listplus_readme.md
 git commit -m "Update listplus directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LISTPLUS
