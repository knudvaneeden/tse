 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 12:23:33]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GENERATE\
 git add generate.s
 git add generate.zip
 git add generate_readme.md
 git commit -m "Update generate directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GENERATE
