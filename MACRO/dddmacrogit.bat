 @REM version: 1.0.0.0.0 [kn, ri, su, 20-09-2026 20:33:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MACRO\
 git add 01.png
 git add macro.dat
 git add macro.doc
 git add macro.ini
 git add macro.mac
 git add macro.qry
 git add macro.s
 git add macro.set
 git add macro.zip
 git add macro1.0.0.0.1.zip
 git add macro_readme.md
 git commit -m "Update macro directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MACRO
