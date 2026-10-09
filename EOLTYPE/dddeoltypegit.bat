 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 00:59:28]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EOLTYPE\
 git add eoltype.s
 git add eoltype.zip
 git add eoltype_readme.md
 git commit -m "Update eoltype directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EOLTYPE
