@REM version: 1.0.0.0.0 [kn, ri, mo, 24-08-2026 01:56:43]-[kn, ri, su, 30-08-2026 19:01:27]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ABREV\
git add abrev.s
git add abrev_readme.md
git add abrev.zip
git commit -m "Update abrev directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ABREV
