@REM version: 1.0.0.0.1 [kn, ri, mo, 24-08-2026 13:54:22]-[kn, ri, su, 30-08-2026 19:17:01]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ANAGRAM\
git add anagram.s
git add anagram_readme.md
git add anagram2.zip
git commit -m "Update anagram directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ANAGRAM
