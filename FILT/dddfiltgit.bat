 @REM version: 1.0.0.0.0 [kn, ri, tu, 08-09-2026 19:03:51]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FILT\
 git add filt.s
 git add filt.zip
 git add filt_readme.md
 git commit -m "Update filt directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FILT
