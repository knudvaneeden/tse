 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 01:22:39]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FPROF104\
 git add findprof.si
 git add fprof104.zip
 git add fprof104_readme.md
 git commit -m "Update fprof104 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FPROF104
