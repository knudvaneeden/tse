@REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 09:50:44]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BLOCKCNT\
git add blockcnt.s
git add blockcnt_readme.md
git add blockcnt.zip
git commit -m "Update blockcnt directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BLOCKCNT
