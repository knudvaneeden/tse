 @REM version: 1.0.0.0.0 [kn, ri, su, 13-09-2026 22:09:11]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\KEYASSIG\
 git add keyassgn.s
 git add keyassig.zip
 git add keyassig_1.0.0.0.39.zip
 git add keyassig_readme.md
 git add keyfind.s
 git add keytable.si
 git commit -m "Update keyassig directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/KEYASSIG
