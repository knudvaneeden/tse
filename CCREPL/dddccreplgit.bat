 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 20:22:37]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CCREPL\
 git add "ccrepl.s"
 git add "ccrepl.zip"
 git add "ccrepl_readme.md"
 git commit -m "Update ccrepl directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CCREPL
