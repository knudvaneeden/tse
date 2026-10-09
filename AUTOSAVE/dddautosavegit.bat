@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 18:32:58]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\AUTOSAVE\
git add autosave.s
git add autosave_readme.md
git add autosave.zip
git commit -m "Update autosave directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/AUTOSAVE
