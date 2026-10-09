 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 19:46:16]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CUAWS57\
 git add burnin.bat
 git add cua.s
 git add cuaws.txt
 git add cuaws57.zip
 git add cuaws57_readme.md
 git add file_id.diz
 git add history.txt
 git add wordstar.ui
 git add wsdiff.txt
 git commit -m "Update cuaws57 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CUAWS57
