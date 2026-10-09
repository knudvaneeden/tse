@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 20:39:14]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BFIND\
git add bfind.s
git add bfind_readme.md
git add bfind.zip
git commit -m "Update bfind directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BFIND
