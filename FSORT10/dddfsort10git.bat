 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 02:42:14]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FSORT10\
 git add fsort.doc
 git add fsort10.zip
 git add fsort10_readme.md
 git add readme.doc
 git commit -m "Update fsort10 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FSORT10
