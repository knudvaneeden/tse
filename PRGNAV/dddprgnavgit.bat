 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 23:32:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PRGNAV\
 git add 01.gif
 git add prgnav.ini
 git add prgnav.zip
 git add prgnav1.0.0.0.1.zip
 git add prgnav_readme.md
 git add vmprgnav.s
 git commit -m "Update prgnav directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PRGNAV
