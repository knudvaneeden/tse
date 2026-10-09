 @REM version: 1.0.0.0.0 [kn, ri, su, 13-09-2026 20:23:31]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\UNICODE\
 git add nameslist.txt
 git add status.s
 git add unicode.s
 git add unicode.zip
 git add unicodedata.txt
 git add unicode_readme.md
 git commit -m "Update unicode directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/UNICODE
