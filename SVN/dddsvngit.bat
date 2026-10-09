@REM version: 1.0.0.0.5 [kn, ri, fr, 21-08-2026 11:58:24]-[kn, ri, fr, 21-08-2026 13:01:12]-[kn, ri, sa, 22-08-2026 17:56:21]-[kn, ri, sa, 22-08-2026 18:49:47]-[kn, ri, su, 23-08-2026 18:18:51]-[kn, ri, mo, 24-08-2026 01:57:38]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\SVN\
git add svn.s
git add svn_readme.md
git commit -m "Update svn directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/SVN
