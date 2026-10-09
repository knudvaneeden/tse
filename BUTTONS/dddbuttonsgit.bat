 @REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 23:48:17]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\BUTTONS\
 git add xbtn.s
 git add sbtn.s
 git add buttons_readme.md
 git add buttons.zip
 git add buttons.doc
 git commit -m "Update buttons directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/BUTTONS
