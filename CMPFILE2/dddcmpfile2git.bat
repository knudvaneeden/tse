 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 22:23:34]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CMPFILE2\
 git add cmpfile2.s
 git add cmpfile2.zip
 git add cmpfile2_readme.md
 git commit -m "Update cmpfile2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CMPFILE2
