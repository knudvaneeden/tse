@REM version: 1.0.0.0.1 [kn, ri, su, 30-08-2026 19:46:56]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BATMENU\
git add batmenu.s
git add batmenu_readme.md
git add batmenu.zip
git add batmenu.dat
git commit -m "Update batmenu directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BATMENU
