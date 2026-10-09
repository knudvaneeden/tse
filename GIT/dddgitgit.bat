@REM version: 1.0.0.0.3 [kn, ri, sa, 22-08-2026 15:43:47]-[kn, ri, sa, 22-08-2026 17:46:52]-[kn, ri, sa, 22-08-2026 17:53:31]-[kn, ri, su, 23-08-2026 18:18:40]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\GIT\
git add git.s
git add git_readme.md
git commit -m "Update git directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/GIT
