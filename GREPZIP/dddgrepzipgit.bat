@REM version: 1.0.0.0.0 [kn, ri, tu, 08-09-2026 13:48:31]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\GREPZIP\
git add grepzip.s
git add grepzip.ini
git add grepzip_helper.ps1
git add grepzip_readme.md
git add grepzip_portable_1.0.0.0.14.zip
git add build.bat
git commit -m "Update grepzip directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/GREPZIP
