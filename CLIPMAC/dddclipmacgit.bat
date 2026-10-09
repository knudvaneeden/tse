 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 19:02:51]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CLIPMAC\
 git add clipmac.zip
 git add clipmac_readme.md
 git add clipper.s
 git commit -m "Update clipmac directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CLIPMAC
