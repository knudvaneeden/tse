 @REM version: 1.0.0.0.0 [kn, ri, we, 09-09-2026 16:00:11]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FINFO_32\
 git add build.bat
 git add fileinfo.s
 git add fileinfo32.dll
 git add finfo32.c
 git add finfo32.def
 git add finfo32.inc
 git add finfo32_compatible_1.0.0.0.1.zip
 git add finfo_32.zip
 git add finfo_32_readme.md
 git add is_read.s
 git add tog_read.s
 git commit -m "Update finfo_32 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FINFO_32
