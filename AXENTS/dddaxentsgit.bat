@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 18:45:38]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\AXENTS\
git add axents.s
git add axents_readme.md
git add axents.zip
git commit -m "Update axents directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/AXENTS
