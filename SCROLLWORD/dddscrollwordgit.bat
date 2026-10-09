@REM version: 1.0.0.0.0 [kn, ri, mo, 21-09-2026 22:06:41]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\SCROLLWORD\
git add 01.png
git add scrollword1.0.0.0.2.zip
git add scrollword.ini
git add scrollword.s
git add scrollword_readme.md
git commit -m "Update scrollword directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/SCROLLWORD
