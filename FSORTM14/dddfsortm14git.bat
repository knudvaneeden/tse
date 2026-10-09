 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 03:15:46]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FSORTM14\
 git add fsortm14.zip
 git add msort.s
 git add fsortm14_readme.md
 git commit -m "Update fsortm14 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FSORTM14
