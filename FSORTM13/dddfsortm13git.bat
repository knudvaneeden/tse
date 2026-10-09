 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 02:47:39]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FSORTM13\
 git add fsortm13.zip
 git add fsortm13_readme.md
 git add msort.s
 git commit -m "Update fsortm13 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FSORTM13
