 @REM version: 1.0.0.0.0 [kn, ri, sa, 12-09-2026 09:27:19]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\JUSTIWS\
 git add justify.s
 git add justiws.zip
 git add justiws_readme.md
 git commit -m "Update justiws directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/JUSTIWS
