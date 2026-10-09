 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 01:06:21]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FOTOPAGE\
 git add fotopage.s
 git add fotopage.zip
 git add fotopage_readme.md
 git commit -m "Update fotopage directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FOTOPAGE
