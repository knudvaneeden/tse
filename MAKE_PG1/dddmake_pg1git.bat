 @REM version: 1.0.0.0.0 [kn, ri, mo, 21-09-2026 12:51:26]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MAKE_PG1\
 git add make_pg1.ini
 git add make_pg1.s
 git add make_pg1.zip
 git add make_pg11.0.0.0.1.zip
 git add make_pg1_readme.md
 git add 01.png
 git commit -m "Update make_pg1 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MAKE_PG1
