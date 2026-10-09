 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 15:16:03]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\INI\
 git add ini.s
 git add ini.si
 git add ini.zip
 git add ini_readme.md
 git commit -m "Update ini directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/INI
