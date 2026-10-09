 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 13:34:12]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\INCBAK21\
 git add incbak.s
 git add incbak21.zip
 git add incbak21_readme.md
 git commit -m "Update incbak21 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/INCBAK21
