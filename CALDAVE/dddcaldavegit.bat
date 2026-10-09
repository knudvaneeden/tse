 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 16:10:41]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CALDAVE\
 git add "calendar.mac"
 git add "calendar.s"
 git add "caldave_readme.md"
 git add "caldave.zip"
 git commit -m "Update caldave directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CALDAVE
