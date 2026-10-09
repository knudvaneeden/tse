 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 18:55:58]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CBLCASE\
 git add "cblcase.s"
 git add "cblcase_readme.md"
 git add "cblcase.zip"
 git commit -m "Update cblcase directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CBLCASE
