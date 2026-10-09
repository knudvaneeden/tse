 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 00:54:07]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FORSYN\
 git add f90.syn
 git add f95.syn
 git add for.syn
 git add forsyn.zip
 git add forsyn_readme.md
 git commit -m "Update forsyn directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FORSYN
