 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 17:28:16]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CAL_ESP\
 git add "cal_esp.s"
 git add "cal_esp.zip"
 git add "cal_esp_readme.md"
 git commit -m "Update cal_esp directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CAL_ESP
