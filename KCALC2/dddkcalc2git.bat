 @REM version: 1.0.0.0.0 [kn, ri, sa, 12-09-2026 20:30:04]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\KCALC2\
 git add kcalc.s
 git add kcalc2.zip
 git add kcalc2_readme.md
 git commit -m "Update kcalc2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/KCALC2
