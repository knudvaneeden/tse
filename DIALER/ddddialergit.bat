 @REM version: 1.0.0.0.0 [kn, ri, sa, 05-09-2026 00:00:04]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DIALER\
 git add dialer.s
 git add dialer.zip
 git add dialer_readme.md
 git commit -m "Update dialer directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DIALER
