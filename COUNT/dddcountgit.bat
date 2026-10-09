 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 02:46:36]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\COUNT\
 git add count.s
 git add count.zip
 git add count_readme.md
 git commit -m "Update count directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/COUNT
