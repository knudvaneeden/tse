 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 22:17:31]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\ISQRT\
 git add isqrt.s
 git add isqrt.zip
 git add isqrt_readme.md
 git commit -m "Update isqrt directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/ISQRT
