 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 00:07:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HIREXP\
 git add hirexp.dat
 git add hirexp.s
 git add hirexp.zip
 git add hirexp_readme.md
 git commit -m "Update hirexp directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HIREXP
