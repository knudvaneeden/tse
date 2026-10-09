 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 01:06:18]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EXECUTE\
 git add execute.s
 git add execute.zip
 git add execute_readme.md
 git commit -m "Update execute directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EXECUTE
