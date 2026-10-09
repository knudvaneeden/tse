@REM version: 1.0.0.0.0 [kn, ri, su, 23-08-2026 21:40:10]-[kn, ri, su, 30-08-2026 18:58:48]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ABANNAME\
git add abanname.s
git add abanname_readme.md
git add abanname.zip
git commit -m "Update abanname directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ABANNAME
