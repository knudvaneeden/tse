 @REM version: 1.0.0.0.0 [kn, ri, mo, 14-09-2026 20:20:52]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LINEPRO\
 git add linepro.s
 git add linepro.zip
  git add linepro_readme.md
 git commit -m "Update linepro directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LINEPRO
