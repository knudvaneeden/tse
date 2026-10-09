 @REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 23:16:53]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NEWBOOKS\
 git add 01.png
 git add newbooks.ini
 git add newbooks.s
 git add newbooks.zip
 git add newbooks1.0.0.0.1.zip
 git add newbooks_readme.md
 git commit -m "Update newbooks directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NEWBOOKS
