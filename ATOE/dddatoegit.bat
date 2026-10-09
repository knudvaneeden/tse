@REM version: 1.0.0.0.[kn, ri, su, 30-08-2026 01:00:27]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ATOE\
git add atoe.s
git add atoe_readme.md
git add ascii_ebcdic.dll
git add atoe.zip
git commit -m "Update atoe directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ATOE
