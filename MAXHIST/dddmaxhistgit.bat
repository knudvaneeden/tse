 @REM version: 1.0.0.0.0 [kn, ri, tu, 22-09-2026 12:30:23]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MAXHIST\
 git add maxhist.ini
 git add maxhist.s
 git add maxhist.zip
 git add maxhist1.0.0.0.0.zip
 git add maxhist_readme.md
 git commit -m "Update maxhist directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MAXHIST
