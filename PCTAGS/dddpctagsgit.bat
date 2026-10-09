 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 14:24:11]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PCTAGS\
 git add pctags.ini
 git add pctags.s
 git add pctags.zip
 git add pctags1.0.0.0.1.zip
 git add pctags_readme.md
 git commit -m "Update pctags directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PCTAGS
