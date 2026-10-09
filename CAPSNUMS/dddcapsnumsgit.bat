 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 18:37:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CAPSNUMS\
 git add "capsnums.s"
 git add "capsnums.zip"
 git add "capsnums_readme.md"
 git add "capsnums.dll"
 git commit -m "Update capsnums directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CAPSNUMS
