@REM version: 1.0.0.0.0 [kn, ri, fr, 28-08-2026 18:20:25]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\FPP\
git add FppPack_1_04_portable.zip
git add fpp_readme.md
git commit -m "Update fpp directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/FPP
