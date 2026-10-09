 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 01:00:27]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COLOREOL\
 git add coloreol.s
 git add coloreol.zip
 git add coloreol_readme.md
 git commit -m "Update coloreol directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COLOREOL
