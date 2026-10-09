 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 20:57:36]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MPGP20\
 git add mpgp.s
 git add mpgp20.zip
 git add mpgp201.0.0.0.7.zip
 git add mpgp20_readme.md
 git add mpgp20.ini
 git add 01.png
 git commit -m "Update mpgp20 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MPGP20
