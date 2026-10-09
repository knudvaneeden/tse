 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 02:53:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COMMENT5\
 git add comment5.s
 git add comment5.zip
 git add comment5_readme.md
 git add file_id.diz
 git commit -m "Update comment5 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COMMENT5
