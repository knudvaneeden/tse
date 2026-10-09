 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 17:57:17]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CAMELCAP\
 git add "camelcaps.inc"
 git add "camelcap.zip"
 git add "camelcap_readme.md"
 git commit -m "Update camelcap directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CAMELCAP
