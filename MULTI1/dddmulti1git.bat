 @REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 12:49:35]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MULTI1\
 git add multi.s
 git add multi1.ini
 git add multi1.zip
 git add multi11.0.0.0.2.zip
 git add multi1_readme.md
 git commit -m "Update multi1 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MULTI1
