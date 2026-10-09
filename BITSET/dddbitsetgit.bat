@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 23:45:36]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BITSET\
git add bitset_readme.md
git add bitset.zip
git add bitsetdll.s
git add bitset.zip
git add bitsetdll.cpp
git add bitsetdll.def
git add bitsetdll_1.0.0.0.5.zip
git add build.bat
git commit -m "Update bitset directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BITSET
