@REM version: 1.0.0.0.0 [kn, ri, fr, 18-09-2026 00:36:44]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\SEARCHCOMPILE\
git commit -m "Update searchcompile directory files"
git add searchcompile.ini
git add searchcompile.s
git add searchcompile1.0.0.0.6.zip
git add searchcompile_readme.md
git add 01.png
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/SEARCHCOMPILE
