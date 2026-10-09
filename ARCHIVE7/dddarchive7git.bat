@REM version: 1.0.0.0.1 [kn, ri, fr, 28-08-2026 16:13:42]-[kn, ri, su, 30-08-2026 19:19:27]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ARCHIVE7\
git add archive7.s
git add archive7_readme.md
git add archive7.zip
git commit -m "Update archive7 directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ARCHIVE7
