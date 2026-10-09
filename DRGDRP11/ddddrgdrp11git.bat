 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 16:01:42]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DRGDRP11\
 git add dragdrop.s
 git add drgdrp11.zip
 git add drgdrp11_readme.md
 git commit -m "Update drgdrp11 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DRGDRP11
