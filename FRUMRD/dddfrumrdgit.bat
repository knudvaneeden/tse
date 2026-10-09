 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 01:29:13]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FRUMRD\
 git add forumrdr.s
 git add frumrd.zip
 git add frumrd_readme.md
 git commit -m "Update frumrd directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FRUMRD
