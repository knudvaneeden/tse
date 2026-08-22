@REM version: 1.0.0.0.3 [kn, ri, th, 20-08-2026 16:44:30]-[kn, ri, fr, 21-08-2026 00:35:42]-[kn, ri, fr, 21-08-2026 13:03:31]-[kn, ri, sa, 22-08-2026 18:00:47]

@echo off
cdd g:\versioncontrol\git\ddd01\saint\
git add saint.s
git add saint_examples.txt
git add saint_rules.txt
git add saint_readme.md
git commit -m "Update saint directory"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/SAINT
