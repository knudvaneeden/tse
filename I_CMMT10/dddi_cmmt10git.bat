 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 22:55:40]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\I_CMMT10\
 git add i_cmmt.s
 git add i_cmmt10.zip
 git add i_cmmt10_readme.md
 git commit -m "Update i_cmmt10 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/I_CMMT10
