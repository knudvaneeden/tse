 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 20:26:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COMPLETE\
 git add complete.mac
 git add complete.s
 git add complete.zip
 git add complete_readme.md
 git add file_id.diz
 git commit -m "Update complete directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COMPLETE
