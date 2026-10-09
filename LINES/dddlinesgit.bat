 @REM version: 1.0.0.0.0 [kn, ri, mo, 14-09-2026 20:54:44]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LINES\
 git add global.si
 git add initpar.si
 git add lines.s
 git add lines.zip
 git add lines_readme.md
 git add poppar.si
 git add procpar.si
 git add pushpar.si
 git commit -m "Update lines directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LINES
