@REM version: 1.0.0.0.1 [kn, ri, fr, 28-08-2026 15:54:47]-[kn, ri, su, 30-08-2026 19:16:46]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ANSI2OEM\
git add ansi2oem.s
git add ansi2oem_readme.md
git add ansi2oem.zip
git commit -m "Update ansi2oem directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ANSI2OEM
