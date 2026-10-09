 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 21:45:30]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CMDLINE3\
 git add cmdexam.s
 git add cmdline.s
 git add cmdline3.zip
 git add cmdline3_readme.md
 git commit -m "Update cmdline3 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CMDLINE3
