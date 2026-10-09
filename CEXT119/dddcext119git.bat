 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 23:01:50]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CEXT119\
 git add "cext119.zip"
 git add "cext119_readme.md"
 git add "currext.s"
 git add "findprof.si"
 git add "sample.ini"
 git add "setcache.si"
 git commit -m "Update cext119 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CEXT119
