 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 01:35:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FS\
 git add fs.s
 git add fs.zip
 git add fs_readme.md
 git commit -m "Update fs directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FS
