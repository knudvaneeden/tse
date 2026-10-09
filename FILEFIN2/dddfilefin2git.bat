 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 22:57:40]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FILEFIN2\
  git add build.bat
  git add ff.dll
  git add ff.s
  git add ff_dll.c
  git add filefin2.ini
  git add filefin2.zip
  git add filefin2_portable_1.0.0.0.30.zip
  git add filefin2_readme.md
  git add zip.dll
  git add zip_dll.c
  git add zip_nested.ps1
 git commit -m "Update filefin2 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FILEFIN2
