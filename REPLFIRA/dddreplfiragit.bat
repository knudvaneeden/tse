@REM version: 1.0.0.0.1 [kn, ri, sa, 29-08-2026 15:12:35]-[kn, ri, sa, 29-08-2026 15:59:52]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\REPLFIRA\
git add replfira.s
git add replfira_readme.md
git commit -m "Update replfira directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/REPLFIRA
