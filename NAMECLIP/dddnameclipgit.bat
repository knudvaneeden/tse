 @REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 21:48:36]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NAMECLIP\
 git add 01.png
 git add nameclip.ini
 git add nameclip.s
 git add nameclip.zip
 git add nameclip1.0.0.0.3.zip
 git add nameclip_readme.md
 git commit -m "Update nameclip directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NAMECLIP
