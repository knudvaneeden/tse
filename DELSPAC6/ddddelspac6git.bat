 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 23:44:01]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DELSPAC6\
 git add delspac6.zip
 git add delspac6_readme.md
 git add delspace.s
 git commit -m "Update delspac6 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DELSPAC6
