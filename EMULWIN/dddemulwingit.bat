 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 00:47:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EMULWIN\
 git add emulwin.ui
 git add emulwin.zip
 git add emulwin_readme.md
 git commit -m "Update emulwin directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EMULWIN
