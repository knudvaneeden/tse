 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 13:11:41]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\OS2CLP08\
 git add os2clip.s
 git add os2clp08.zip
 git add os2start.s
 git commit -m "Update os2clp08 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/OS2CLP08
