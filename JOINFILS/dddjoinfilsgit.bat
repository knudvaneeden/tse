n @REM version: 1.0.0.0.0 [kn, ri, sa, 12-09-2026 00:30:42]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\JOINFILS\
 git add joinfils.s
 git add joinfils.zip
 git add joinfils_readme.md
 git add sort.s
 git commit -m "Update joinfils directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/JOINFILS
