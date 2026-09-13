 @REM version: 1.0.0.0.0 [kn, ri, su, 13-09-2026 18:13:31]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SPEAK02\
 git add dddspeak02git.bat
 git add dllmain.cpp
 git add speak.cpp
 git add speak.def
 git add speak.dll
 git add speak.h
 git add speak.s
 git add speak.sln
 git add speak.vcproj
 git add speak02.zip
 git add speak02_readme.md
 git add speak_readme.txt
 git add stdafx.cpp
 git add stdafx.h
 git add targetver.h
 git commit -m "Update speak02 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SPEAK02
