 @REM version: 1.0.0.0.0 [kn, ri, fr, 25-09-2026 18:16:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\SEARCHFILEEXECMACROINCLUDE\

 git add 01.gif
 git add searchfileexecmacroinclude.ini
 git add searchfileexecmacroinclude.s
 git add searchfileexecmacroinclude1.0.0.0.11.zip
 git add searchfileexecmacroinclude_readme.md
 git commit -m "Update searchfileexecmacroinclude directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/SEARCHFILEEXECMACROINCLUDE
