@REM version: 1.0.0.0.0 [kn, ri, su, 30-08-2026 22:32:43]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BIBLER21\
git add -f bibleres.s
git add -f bibler21_readme.md
git add -f bibler21.zip
git add -f bullets.s
git add -f rewrap.s
git add -f kjv.txt
git commit -m "Update bibler21 directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BIBLER21
