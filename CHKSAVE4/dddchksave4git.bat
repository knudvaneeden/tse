 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 00:44:13]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CHKSAVE4\
 git add "chksave.s"
 git add "chksave4.zip"
 git add "chksave4_readme.md"
 git commit -m "Update chksave4 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CHKSAVE4
