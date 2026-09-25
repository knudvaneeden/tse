 @REM version: 1.0.0.0.0 [kn, ri, fr, 25-09-2026 01:50:04]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NOLINES\
 git commit -m "Update nolines directory files"\
 git add 01.png
 git add clipbor2.zip
 git add clipbord.s
 git add dddnolinesgit.bat
 git add dospar.s
 git add global.si
 git add global.zip
 git add initpar.si
 git add macpar3.zip
 git add nolines.ini
 git add nolines.s
 git add nolines.zip
 git add nolines1.0.0.0.4.zip
 git add nolines_readme.md
 git add par.doc
 git add poppar.si
 git add procpar.si
 git add pushpar.si
 git add testpar.s
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NOLINES
