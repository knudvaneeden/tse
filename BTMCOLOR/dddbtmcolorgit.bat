 @REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 22:07:09]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\BTMCOLOR\
 git add btmcolor.txt
 git add btmcolor_readme.md
 git add btmcolor.zip
 git commit -m "Update btmcolor directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/BTMCOLOR
