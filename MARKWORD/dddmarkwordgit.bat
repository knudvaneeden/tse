 @REM version: 1.0.0.0.0 [kn, ri, mo, 21-09-2026 20:42:51]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MARKWORD\
 git add 01.png
 git add markword.ini
 git add markword.s
 git add markword.zip
 git add markword1.0.0.0.1.zip
 git add markword_readme.md
 git commit -m "Update markword directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MARKWORD
