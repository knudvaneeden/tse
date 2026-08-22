@REM version: 1.0.0.0.3 [kn, ri, fr, 21-08-2026 00:02:49] [kn, ri, fr, 21-08-2026 03:40:49]-[kn, ri, fr, 21-08-2026 13:05:29]-[kn, ri, fr, 21-08-2026 13:07:20]

@echo off
cdd g:\versioncontrol\git\ddd01\viewfinds\
git checkout TRUNK
git add ViewFinds.s
git add ViewFinds_readme.md
git commit -m "Update viewfinds directory files"
git push origin TRUNK
https://github.com/knudvaneeden/tse/tree/TRUNK/VIEWFINDS
