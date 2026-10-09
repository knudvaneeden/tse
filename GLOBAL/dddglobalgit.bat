 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 13:56:54]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GLOBAL\
 git add global.si
 git add global.zip
 git add global_readme.md
 git commit -m "Update global directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GLOBAL
