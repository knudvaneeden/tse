 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 19:56:37]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GREP3230\
 git add build.bat
 git add compat.si
 git add dialog.s
 git add dialog.si
 git add dialogp.s
 git add dlg222.zip
 git add gethelp.dat
 git add gethelp.hlp
 git add gethelp.k32
 git add gethelp.si
 git add gethlp40.zip
 git add grep.hlp
 git add grep.s
 git add grep3230.zip
 git add grep3230ALL.zip
 git add grep3230_readme.md
 git add grepdlg.d
 git add grepdlg.dlg
 git add grepdlg.si
 git add guiinc.inc
 git add helphelp.mac
 git add helphelp.s
 git add scpaint.si
 git add scwinclp.si
 git commit -m "Update grep3230 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GREP3230
