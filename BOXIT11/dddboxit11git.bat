@REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 10:26:51]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BOXIT11\
git add boxit.s
git add boxit11_readme.md
git add boxit11.zip
git commit -m "Update boxit11 directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BOXIT11
