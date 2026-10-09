@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 15:28:55]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\VIEWBLTT\
git add viewbltt.s
git add viewbltt_readme.md
git commit -m "Update viewbltt directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/VIEWBLTT
