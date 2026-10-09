 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 20:09:00]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FILEBASE\
 git add filebase.s
 git add filebase.zip
 git add filebase_readme.md
 git add symtab.s
 git commit -m "Update filebase directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FILEBASE
