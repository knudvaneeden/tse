@REM version: 1.0.0.0.1 [kn, ri, fr, 21-08-2026 11:58:24]-[kn, ri, fr, 21-08-2026 13:01:12]

@echo off
cdd g:\versioncontrol\git\ddd01\svn\
git checkout TRUNK
git add svn.s
git add svn_readme.md
git commit -m "Update svn directory files"
git push origin TRUNK
https://github.com/knudvaneeden/tse/tree/TRUNK/SVN
