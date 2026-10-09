 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 13:35:34]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GETFISME\
 git add getfisme.s
 git add getfisme.zip
 git add getfisme_readme.md
 git commit -m "Update getfisme.zip directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GETFISME
