@REM version: 1.0.0.0.0 [kn, ri, fr, 18-09-2026 15:22:06]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\FOLDING\
git add folding.s
git add folding.ini
git add folding_readme.md
git add folding1.0.0.0.3.zip
git commit -m "Update folding directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/FOLDING
