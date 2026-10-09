@REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 00:02:22]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BLK_1\
git add blocks.s
git add blk_1_readme.md
git add blk_1.zip
git commit -m "Update blk_1 directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BLK_1
