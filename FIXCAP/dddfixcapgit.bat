 @REM version: 1.0.0.0.0 [kn, ri, we, 09-09-2026 18:40:15]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FIXCAP\
 git add fixcap.s
 git add fixcap.zip
 git add fixcap_readme.md
 git commit -m "Update fixcap directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FIXCAP
