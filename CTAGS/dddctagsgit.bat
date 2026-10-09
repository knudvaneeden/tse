 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 19:07:46]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CTAGS\
 git add ctags.s
 git add ctags.zip
 git add ctags_readme.md
 git commit -m "Update ctags directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CTAGS
