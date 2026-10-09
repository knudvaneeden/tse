@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 20:59:58]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BFINDR\
git add b_findr.s
git add bfindr_readme.md
git add bfindr.zip
git commit -m "Update bfindr directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BFINDR
