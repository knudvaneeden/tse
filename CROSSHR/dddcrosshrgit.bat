 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 15:26:24]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CROSSHR\
 git add crosshair.mac
 git add crosshair.s
 git add crosshr.zip
 git add crosshr_readme.md
 git add file_id.diz
 git commit -m "Update crosshr directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CROSSHR
