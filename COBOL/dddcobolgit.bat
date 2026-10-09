 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 00:23:39]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COBOL\
 git add bakspac2.s
 git add cobol.zip
 git add cobol_readme.md
 git add settabs2.s
 git add tab2.s
 git commit -m "Update cobol directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COBOL
