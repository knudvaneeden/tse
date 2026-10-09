 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 00:14:24]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EDITEDI\
 git add editedi.s
 git add editedi.zip
 git add editedi_readme.md
 git commit -m "Update editedi directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EDITEDI
