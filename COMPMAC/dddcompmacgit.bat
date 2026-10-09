 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 20:34:52]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COMPMAC\
 git add compmac.zip
 git add compmac_readme.md
 git add c_macs.s
 git commit -m "Update compmac directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COMPMAC
