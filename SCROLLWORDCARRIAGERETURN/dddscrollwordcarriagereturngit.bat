@REM version: 1.0.0.0.0 [kn, ri, fr, 25-09-2026 23:38:20]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\SCROLLWORDCARRIAGERETURN\
 git add scrollwordcarriagereturn.ini
 git add scrollwordcarriagereturn.s
 git add scrollwordcarriagereturn1.0.0.0.1.zip
 git add scrollwordcarriagereturn_readme.md
git commit -m "Update scrollwordcarriagereturn directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/SCROLLWORDCARRIAGERETURN
