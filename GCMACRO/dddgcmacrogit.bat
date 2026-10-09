 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 11:44:05]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GCMACRO\
 git add block.s
 git add gcmacro.zip
 git add gcmacro_readme.md
 git add macros
 git add readme
 git add scroll.s
 git add ss.s
 git add ss1word.s
 git commit -m "Update gcmacro directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GCMACRO
