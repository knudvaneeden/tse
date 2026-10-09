 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 00:37:31]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EFIND\
 git add efind.inc
 git add efind.ini
 git add efind.s
 git add efind.zip
 git add efind_knud.zip
 git add efind_readme.md
 git add elist.s
 git add file_id.diz
 git add readme.txt
 git add setwiyde.s
 git add videoefind.mpg
 git add zipinstallefind.bat
 git commit -m "Update efind directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EFIND
