@REM version: 1.0.0.0.1 [kn, ri, su, 23-08-2026 21:05:41]-[kn, ri, su, 30-08-2026 18:59:05]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\1LINER\
git add 1liner.s
git add 1liner_readme.md
git add 1liner2.zip
git commit -m "Update 1liner directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/1LINER
