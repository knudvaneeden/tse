 @REM version: 1.0.0.0.0 [kn, ri, mo, 28-09-2026 02:18:48]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SEARCHHELPTSE\
 git add dddsearchhelptsegit.bat
 git add searchhelptse.zip
 git add tsehelp.s
 git add searchhelptse_readme.md
 git add searchhelptse.ini
 git add 01.png
 git commit -m "Update searchhelptse directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SEARCHHELPTSE
