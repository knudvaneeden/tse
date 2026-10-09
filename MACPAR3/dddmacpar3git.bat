 @REM version: 1.0.0.0.0 [kn, ri, su, 20-09-2026 19:59:28]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MACPAR3\
 git add dospar.s
 git add initpar.si
 git add macpar3.zip
 git add par.doc
 git add poppar.si
 git add procpar.si
 git add pushpar.si
 git add testpar.s
 git add global.si
 git add macpar3.ini
 git add macpar31.0.0.0.0.zip
 git commit -m "Update macpar3 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MACPAR3
