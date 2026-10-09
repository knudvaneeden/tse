 @REM version: 1.0.0.0.0 [kn, ri, su, 13-09-2026 17:22:01]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SPEAK\
 git add speak.dll
 git add speak.s
 git add speak.zip
 git add speak_readme.md
 git commit -m "Update speak directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SPEAK
