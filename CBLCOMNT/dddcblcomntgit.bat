 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 19:58:10]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CBLCOMNT\
 git add "cblcomnt.s"
 git add "cblcomnt.zip"
 git add "cblcomnt_readme.md"
 git commit -m "Update cblcomnt directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CBLCOMNT
