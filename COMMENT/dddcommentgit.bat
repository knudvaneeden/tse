 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 02:36:03]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COMMENT\
 git add comment.s
 git add comment.zip
 git add comment_readme.md
 git commit -m "Update comment directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COMMENT
