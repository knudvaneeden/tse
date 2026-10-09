 @REM version: 1.0.0.0.0 [kn, ri, tu, 08-09-2026 19:21:05]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FILT100\
 git add filt100.zip
 git add filt100_readme.md
 git add filter.ui
 git add find.s
 git add null.s
 git commit -m "Update filt100 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FILT100
