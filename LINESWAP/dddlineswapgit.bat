 @REM version: 1.0.0.0.0 [kn, ri, mo, 14-09-2026 23:53:41]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LINESWAP\
 git add lineswap.s
 git add lineswap.zip
 git add lineswap_readme.md
 git commit -m "Update lineswap directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LINESWAP
