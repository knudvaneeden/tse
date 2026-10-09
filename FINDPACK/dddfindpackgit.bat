 @REM version: 1.0.0.0.0 [kn, ri, tu, 08-09-2026 23:29:13]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FINDPACK\
 git add findpack.s
 git add findpack.zip
 git add findpack_readme.md
 git commit -m "Update findpack directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FINDPACK
