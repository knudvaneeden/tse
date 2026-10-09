 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 15:31:21]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DOCMODE\
 git add autowrap.s
 git add dautowrp.s
 git add docmode.s
 git add docmode.zip
 git add docmode_readme.md
 git commit -m "Update docmode directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DOCMODE
