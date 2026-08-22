@REM version: 1.0.0.0.4 [kn, ri, fr, 21-08-2026 00:02:49] [kn, ri, fr, 21-08-2026 03:40:49]-[kn, ri, fr, 21-08-2026 13:05:29]-[kn, ri, fr, 21-08-2026 13:07:20]-[kn, ri, sa, 22-08-2026 18:03:54]

@echo off
cdd g:\versioncontrol\git\ddd01\viewfinds\
git add ViewFinds.s
git add ViewFinds_readme.md
git commit -m "Update viewfinds directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/VIEWFINDS
