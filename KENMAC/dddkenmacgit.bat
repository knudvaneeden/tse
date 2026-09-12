 @REM version: 1.0.0.0.0 [kn, ri, su, 13-09-2026 00:22:52]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\KENMAC\
 git add dddkenmacgit.bat
 git add kenmac.zip
 git add ken_macs.s
 git commit -m "Update kenmac directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/KENMAC
