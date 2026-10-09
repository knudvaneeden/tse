@REM version: 1.0.0.0.0 [kn, ri, th, 17-09-2026 20:54:29]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\SEARCHTEMPLATE\
git add searchtemplate.s
git add searchtemplate.ini
git add searchtemplate1.0.0.0.5.zip
git add searchtemplate_readme.md
git commit -m "Update searchtemplate directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/SEARCHTEMPLATE
