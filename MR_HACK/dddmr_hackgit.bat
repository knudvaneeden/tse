 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 17:47:36]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MR_HACK\
 git add 01.png
 git add mr_hack.ini
 git add mr_hack.s
 git add mr_hack.zip
 git add mr_hack1.0.0.0.0.zip
 git add mr_hack_readme.md
 git commit -m "Update mr_hack directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MR_HACK
