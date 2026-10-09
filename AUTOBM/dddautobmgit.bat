@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 01:24:02]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\AUTOBM\
git add autobm.s
git add autobm_readme.md
git add autobm.zip
git commit -m "Update autobm directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/AUTOBM
