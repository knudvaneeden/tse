 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 01:21:07]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HTML100E\
 git add html100e.zip
 git add html100e_readme.md
 git add html_e.s
 git commit -m "Update html100e directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HTML100E
