 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 13:44:19]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\INCSEA\
 git add incrsrch.s
 git add incsea.zip
 git add incsea_readme.md
 git commit -m "Update incsea directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/INCSEA
