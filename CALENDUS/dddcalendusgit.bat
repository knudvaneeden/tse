 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 16:41:06]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CALENDUS\
 git add "calendus.s"
 git add "calendus_readme.md"
 git add "calendus.zip"
 git commit -m "Update calendus directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CALENDUS
