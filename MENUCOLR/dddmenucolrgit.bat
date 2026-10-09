 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 12:49:36]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MENUCOLR\
 git add menucolr.ini
 git add menucolr.s
 git add menucolr.zip
 git add menucolr1.0.0.0.2.zip
 git add menucolr_readme.md
 git add 01.png
 git commit -m "Update menucolr directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MENUCOLR
