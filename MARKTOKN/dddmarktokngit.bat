 @REM version: 1.0.0.0.0 [kn, ri, mo, 21-09-2026 20:02:29]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MARKTOKN\
 git add 01.png
 git add marktokn.ini
 git add marktokn.s
 git add marktokn.zip
 git add marktokn1.0.0.0.1.zip
 git add marktokn_readme.md
 git commit -m "Update marktokn directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MARKTOKN
