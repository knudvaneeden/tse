 @REM version: 1.0.0.0.0 [kn, ri, th, 08-10-2026 17:23:44]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SHORTNAME\
 git commit -m "Update shortname directory files"
 git add 01.gif
 git add shortname.ini
 git add shortname.s
 git add shortname1.0.0.0.2.zip
 git add shortname_readme.md
 git add test83.txt
 git add 2287~1.txt
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SHORTNAME
