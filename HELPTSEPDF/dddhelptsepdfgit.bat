 @REM version: 1.0.0.0.0 [kn, ri, mo, 05-10-2026 17:16:05]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HELPTSEPDF\
 git add helptsepdf.ini
 git add helptsepdf.s
 git add helptsepdf1.0.0.0.0.zip
 git add helptsepdf_readme.md
 git add testhelphyperlinktseadobe.pdf
 git commit -m "Update helptsepdf directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HELPTSEPDF
