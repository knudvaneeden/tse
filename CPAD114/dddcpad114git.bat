 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 14:56:50]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CPAD114\
 git add codepad.s
 git add codepad.txt
 git add cpad114.zip
 git add cpad114_readme.md
 git add file_id.diz
 git add findprof.si
 git add setcache.si
 git add profile.s
 git add profile.si
 git add profile.txt
 git commit -m "Update cpad114 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CPAD114
