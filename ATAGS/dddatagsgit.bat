@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 00:38:06]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ATAGS\
git add atags.s
git add atags_readme.md
git add atags.zip
git commit -m "Update atags directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ATAGS
