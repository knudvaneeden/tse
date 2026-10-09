 @REM version: 1.0.0.0.0 [kn, ri, mo, 07-09-2026 00:29:52]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\EDWIHTSE\
 git add edwihtse.s
 git add edwihtse.zip
 git add edwihtse_readme.md
 git commit -m "Update edwihtse directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/EDWIHTSE
