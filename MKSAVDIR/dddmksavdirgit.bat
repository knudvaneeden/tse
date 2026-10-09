 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 14:25:09]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MKSAVDIR\
 git add 01.png
 git add mksavdir.ini
 git add mksavdir.s
 git add mksavdir.zip
 git add mksavdir1.0.0.0.0.zip
 git add mksavdir_readme.md
 git commit -m "Update mksavdir directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MKSAVDIR
