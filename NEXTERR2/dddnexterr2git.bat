 @REM version: 1.0.0.0.0 [kn, ri, fr, 25-09-2026 01:13:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NEXTERR2\
 git add 01.png
 git add nexterr2.ini
 git add nexterr2.s
 git add nexterr2.zip
 git add nexterr21.0.0.0.2.zip
 git add nexterr2_readme.md
 git commit -m "Update nexterr2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NEXTERR2
