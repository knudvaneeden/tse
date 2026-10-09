 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 23:26:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DTMENU\
 git add dtmenu.s
 git add dtmenu.zip
 git add dtmenu_readme.md
 git commit -m "Update dtmenu directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DTMENU
