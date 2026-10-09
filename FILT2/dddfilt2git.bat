 @REM version: 1.0.0.0.0 [kn, ri, tu, 08-09-2026 20:03:27]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FILT2\
 git add filt.s
 git add filt2.zip
 git add filt2_readme.md
 git commit -m "Update filt2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FILT2
