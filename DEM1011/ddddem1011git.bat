 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 23:52:25]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DEM1011\
 git add dem.s
 git add dem1011.zip
 git add dem1011_readme.md
 git commit -m "Update dem1011 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DEM1011
