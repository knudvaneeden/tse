 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 22:34:47]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DSPELL\
 git add copying
 git add dspell.s
 git add dspell.zip
 git add dspell_readme.md
 git commit -m "Update dspell directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DSPELL
