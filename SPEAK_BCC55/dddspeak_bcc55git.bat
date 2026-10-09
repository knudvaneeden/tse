 @REM version: 1.0.0.0.0 [kn, ri, su, 13-09-2026 18:13:31]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SPEAK_BCC55\
 git add build.bat
 git add speak.def
 git add speak.dll
 git add speak.mac
 git add speak.s
 git add speak_bcc55.cpp
 git add speak_bcc55_1.0.0.0.0.zip
 git add speak_bcc55_readme.md
 git commit -m "Update speak_bcc55 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SPEAK_BCC55
