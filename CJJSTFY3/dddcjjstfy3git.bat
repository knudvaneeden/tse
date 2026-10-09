 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 01:08:26]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CJJSTFY3\
 git add "cjjstfy.s"
 git add "cjjstfy3.zip"
 git add "cjjstfy3_readme.md"
 git commit -m "Update cjjstfy3 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CJJSTFY3
