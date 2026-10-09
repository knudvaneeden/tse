@REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 10:13:10]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BOOKMRK3\
git add book.s
git add bookmrk3_readme.md
git add bookmrk3.zip
git commit -m "Update bookmrk3 directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BOOKMRK3
