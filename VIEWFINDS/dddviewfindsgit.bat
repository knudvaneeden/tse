@REM version: 1.0.0.0.0 [kn, ri, fr, 21-08-2026 00:02:49]

@echo off
cdd g:\versioncontrol\git\ddd01\viewfinds\
git checkout TRUNK
git add .
git commit -m "Update viewfinds directory"
git push origin TRUNK
