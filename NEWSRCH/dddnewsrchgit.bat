 @REM version: 1.0.0.0.0 [kn, ri, fr, 25-09-2026 01:03:19]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NEWSRCH\
 git add newsrch.ini
 git add newsrch.s
 git add newsrch.zip
 git add newsrch1.0.0.0.0.zip
 git add newsrch_readme.md
 git commit -m "Update newsrch directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NEWSRCH
