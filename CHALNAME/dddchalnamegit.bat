 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 23:17:39]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CHALNAME\
 git add "chalname.s"
 git add "chalname.zip"
 git add "chalname_readme.md"
 git commit -m "Update chalname directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CHALNAME
