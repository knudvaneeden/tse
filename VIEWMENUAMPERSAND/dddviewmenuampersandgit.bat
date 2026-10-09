@REM version: 1.0.0.0.2 [kn, ri, su, 23-08-2026 17:29:02]-[kn, ri, su, 23-08-2026 17:43:08]-[kn, ri, su, 23-08-2026 17:54:24]

@echo off
cd /d g:\versioncontrol\git\ddd01\VIEWMENUAMPERSAND\
git add viewmenuampersand.s
git add viewmenuampersand_readme.md
git commit -m "Update viewmenuampersand directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/VIEWMENUAMPERSAND
