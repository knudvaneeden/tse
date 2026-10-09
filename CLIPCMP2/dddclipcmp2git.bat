 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 18:52:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CLIPCMP2\
 git add clipcmp2.zip
 git add clipcmp2_readme.md
 git add clipcomp.s
 git commit -m "Update clipcmp2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CLIPCMP2
