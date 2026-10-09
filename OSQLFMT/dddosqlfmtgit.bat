 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 13:28:26]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\OSQLFMT\
 git add intarray.si
 git add osqlfmt.ini
 git add osqlfmt.s
 git add osqlfmt.zip
 git add osqlfmt1.0.0.0.0.zip
 git add osqlfmt_readme.md
 git commit -m "Update osqlfmt directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/OSQLFMT
