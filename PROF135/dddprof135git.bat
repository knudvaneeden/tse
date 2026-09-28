 @REM version: 1.0.0.0.0 [kn, ri, mo, 28-09-2026 16:13:11]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PROF135\
 git add dddprof135git.bat
 git add prof135.ini
 git add prof135.zip
 git add prof1351.0.0.0.8.zip
 git add prof135backup.ini
 git add prof135_readme.md
 git add profile.mac
 git add profile.s
 git add profile.si
 git add profile.txt
 git add 01.gif
 git commit -m "Update prof135 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PROF135
