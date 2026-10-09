 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 22:51:59]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DBEDIT2\
 git add dbedit.s
 git add dbedit2.zip
 git add dbedit2_readme.md
 git commit -m "Update dbedit2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DBEDIT2
