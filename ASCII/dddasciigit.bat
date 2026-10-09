@REM version: 1.0.0.0.0 [kn, ri, sa, 29-08-2026 17:08:22]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ASCII\
git add ascii.s
git add ascii_readme.md
git add asciidll.c
git add asciidll.def
git add asciidll.dll
git add build.bat
git add ascii_dll_1.0.0.0.4.zip
git add ascii.zip
git commit -m "Update ascii directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ASCII
