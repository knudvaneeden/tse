 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 00:31:01]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FOLD131U\
 git add fold.cfg
 git add fold.s
 git add fold131u.zip
 git add fold131u_readme.md
 git commit -m "Update fold131u directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FOLD131U
