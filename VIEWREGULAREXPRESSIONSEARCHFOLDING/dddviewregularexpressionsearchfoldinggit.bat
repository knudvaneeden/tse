@REM version: 1.0.0.0.0 [kn, ri, mo, 28-09-2026 10:39:15]l

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\VIEWREGULAREXPRESSIONSEARCHFOLDING\
 git add 01.gif
 git add viewregularexpressionsearchfolding.ini
 git add viewregularexpressionsearchfolding.s
 git add viewregularexpressionsearchfolding1.0.0.0.1.zip
 git add viewregularexpressionsearchfolding_readme.md
 git add _01.png
 git add _02.png
 git add _03.png
 git add _04.png
 git add _05.png
git commit -m "Update viewregularexpressionsearchfolding directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/VIEWREGULAREXPRESSIONSEARCHFOLDING
