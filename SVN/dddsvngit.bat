@REM version: 1.0.0.0.3 [kn, ri, fr, 21-08-2026 11:58:24]-[kn, ri, fr, 21-08-2026 13:01:12]-[kn, ri, sa, 22-08-2026 17:56:21]-[kn, ri, sa, 22-08-2026 18:49:47]

@echo off
cdd g:\versioncontrol\git\ddd01\svn\
git add svn.s
git add svn_readme.md
git commit -m "Update svn directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/SVN
