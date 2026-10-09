 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 18:25:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PICKLIST\
 git add picklist.ini
 git add picklist.s
 git add picklist.zip
 git add picklist1.0.0.0.0.zip
 git add picklist_readme.md
 git commit -m "Update picklist directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PICKLIST
