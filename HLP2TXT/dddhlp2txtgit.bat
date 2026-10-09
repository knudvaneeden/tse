 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 00:29:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HLP2TXT\
 git add hlp2txt.s
 git add hlp2txt.zip
 git add hlp2txt_readme.md
 git commit -m "Update hlp2txt directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HLP2TXT
