 @REM version: 1.0.0.0.0 [kn, ri, we, 09-09-2026 23:24:18]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FNEXP105\
 git add fnexp.s
 git add fnexp.txt
 git add fnexp105.zip
 git add fnexp105_readme.md
 git add ini.s
 git add ini.si
 git commit -m "Update fnexp105 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FNEXP105
