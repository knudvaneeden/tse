@REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 15:06:08]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\FILEOPENFOO\
git add 01.png
git add fileopenfoo_readme.md
git add foo.c
git add foo.exe
git commit -m "Update fileopenfoo directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/FILEOPENFOO
