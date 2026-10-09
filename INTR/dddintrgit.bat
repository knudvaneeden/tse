 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 19:19:17]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\INTR\
 git add build.bat
 git add intr.zip
 git add intr32.c
 git add intr32.def
 git add intr32.dll
 git add intr32.inc
 git add intr32.s
 git add intr32_dll_1.0.0.0.2.zip
 git add intr_readme.md
 git commit -m "Update intr directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/INTR
