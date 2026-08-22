@REM version: 1.0.0.0.2 [kn, ri, sa, 22-08-2026 15:43:47]-[kn, ri, sa, 22-08-2026 17:46:52]-[kn, ri, sa, 22-08-2026 17:53:31]

@echo off
cdd g:\versioncontrol\git\ddd01\git\
git add git.s
git add git_readme.md
git commit -m "Update git directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/GIT
