 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 16:16:54]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DSPELL-E\
 git add dspell-e.zip
 git add dspell.s
 git add dspell.hlp
 git add dspell.si
 git add dspell2.s
 git add ini.s
 git add ini.si
 git add dspell-e_readme.md
 git commit -m "Update dspell-e directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DSPELL-E
