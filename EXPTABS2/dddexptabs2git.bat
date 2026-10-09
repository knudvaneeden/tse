 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 01:28:07]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EXPTABS2\
 git add exptabs.s
 git add exptabs2.zip
 git add exptabs2_readme.md
 git commit -m "Update exptabs2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EXPTABS2
