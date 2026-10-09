 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 17:08:08]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CSV2FLV\
 git add csv2flv.s
 git add csv2flv.zip
 git add csv2flv_readme.md
 git add file_id.diz
 git commit -m "Update csv2flv directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CSV2FLV
