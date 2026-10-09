 @REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 01:02:52]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MSPATFOLD\
 git add 01.png
 git add fold.s
 git add fold_me.1st
 git add mspatfold.ini
 git add mspatfold.zip
 git add mspatfold_readme.md
 git add mspatfold1.0.0.0.9.zip
 git commit -m "Update mspatfold directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MSPATFOLD
