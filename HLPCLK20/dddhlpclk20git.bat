 @REM version: 1.0.0.0.0 [kn, ri, fr, 11-09-2026 00:37:24]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\HLPCLK20\
 git add hlpclk20.zip
 git add hlpclk20_readme.md
 git add hlplnclk.s
 git commit -m "Update hlpclk20 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/HLPCLK20
