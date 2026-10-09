 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 16:07:41]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CLIPBOR2\
 git add clipbor2.zip
 git add clipbor2_readme.md
 git add clipbord.s
 git add global.si
 git add initpar.si
 git add poppar.si
 git add procpar.si
 git add pushpar.si
 git commit -m "Update clipbor2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CLIPBOR2
