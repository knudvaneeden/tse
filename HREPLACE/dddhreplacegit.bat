 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 00:46:23]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HREPLACE\
 git add hreplace.s
 git add hreplace.zip
 git add hreplace_readme.md
 git commit -m "Update hreplace directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HREPLACE
