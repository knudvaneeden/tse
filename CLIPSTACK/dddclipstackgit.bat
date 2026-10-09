@REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 18:02:17]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\CLIPSTACK\
git add clipstack_demo.s
git add clipstack_readme.md
git add clipstack.inc
git commit -m "Update clipstack directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/CLIPSTACK
