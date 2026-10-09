 @REM version: 1.0.0.0.0 [kn, ri, tu, 08-09-2026 17:47:27]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FILLNUM2\
 git add fillnum.s
 git add fillnum2.zip
 git add fillnum2_readme.md
 git commit -m "Update fillnum2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FILLNUM2
