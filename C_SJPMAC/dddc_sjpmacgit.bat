 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 22:09:05]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\C_SJPMAC\
 git add c_sjpmac.s
 git add c_sjpmac.zip
 git add c_sjpmac_readme.md
 git commit -m "Update c_sjpmac directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/C_SJPMAC
