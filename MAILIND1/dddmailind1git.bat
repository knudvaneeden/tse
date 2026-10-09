 @REM version: 1.0.0.0.0 [kn, ri, su, 20-09-2026 22:26:42]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\MAILIND1\
 @REM not added here for security purposes (e.g. email addresses): 01.png
 git add mail.s
 git add mailind1.ini
 git add mailind1.zip
 git add mailind11.0.0.0.2.zip
 git add mailind1_readme.md
 git commit -m "Update mailind1 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/MAILIND1
