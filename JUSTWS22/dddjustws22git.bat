 @REM version: 1.0.0.0.0 [kn, ri, sa, 12-09-2026 15:58:23]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\JUSTWS22\
 git add justws22.s
 git add justws22.zip
 git add justws22_readme.md
 git commit -m "Update justws22 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/JUSTWS22
