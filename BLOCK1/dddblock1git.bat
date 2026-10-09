@REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 00:25:35]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BLOCK1\
git add block.inc
git add block1_readme.md
git add block1.zip
git commit -m "Update block1 directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BLOCK1
