 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 15:12:13]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PGPTSEAW\
 git add hwinsiz.s
 git add pgpalt.hlp
 git add pgpaw.s
 git add pgprefcd.txt
 git add pgptseaw.ini
 git add pgptseaw.zip
 git add pgptseaw1.0.0.0.0.zip
 git add pgptseaw_readme.md
 git commit -m "Update pgptseaw directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PGPTSEAW
