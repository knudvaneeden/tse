 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 00:08:50]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\BYTBIT\
 git add byte2bit.s
 git add byte2bit.txt
 git add bytbit_readme.md
 git add bytbit.zip
 git commit -m "Update bytbit directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/BYTBIT
