@REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 23:27:46]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\GETSTDGF\
git add getstdgf.s
git add getstdgf_readme.md
git commit -m "Update getstdgf directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/GETSTDGF
