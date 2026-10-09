 @REM version: 1.0.0.0.0 [kn, ri, sa, 19-09-2026 19:03:35]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LOPENFIX\
 git add lopenfix.ini
 git add lopenfix.s
 git add lopenfix.zip
 git add lopenfix1.0.0.0.6.zip
 git add lopenfix_readme.md
 git commit -m "Update lopenfix directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LOPENFIX
