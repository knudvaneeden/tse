 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 13:25:44]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GETHLP40\
 git add compat.si
 git add gethelp.dat
 git add gethelp.exe
 git add gethelp.hlp
 git add gethelp.k32
 git add gethelp.mac
 git add gethelp.si
 git add gethlp40.zip
 git add guiinc.inc
 git add help26.hlp
 git add help28.hlp
 git add help30.hlp
 git add helphelp.s
 git commit -m "Update gethlp40 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GETHLP40
