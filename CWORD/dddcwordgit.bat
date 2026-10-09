 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 22:00:12]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CWORD\
 git add cword.s
 git add cword.zip
 git add cword_readme.md
 git commit -m "Update cword directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CWORD
