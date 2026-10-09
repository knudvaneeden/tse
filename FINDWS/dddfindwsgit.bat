 @REM version: 1.0.0.0.0 [kn, ri, we, 09-09-2026 15:39:53]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FINDWS\
 git add findws.s
 git add findws.zip
 git add findws_readme.md
 git commit -m "Update findws directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FINDWS
