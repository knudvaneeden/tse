 @REM version: 1.0.0.0.0 [kn, ri, fr, 18-09-2026 17:15:01]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PGFX25\
 git add pgfx25.ini
 git add pgfx25.s
 git add pgfx25.zip
 git add pgfx25.pgfx251.0
 git add pgfx25_readme.md
 git commit -m "Update pgfx25 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PGFX25
