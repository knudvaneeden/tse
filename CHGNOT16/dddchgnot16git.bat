 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 00:35:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CHGNOT16\
 git add "chgnot16.zip"
 git add "chgnot16_readme.md"
 git add "chgnotif.dll"
 git add "chgnotif.s"
 git commit -m "Update chgnot16 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CHGNOT16
