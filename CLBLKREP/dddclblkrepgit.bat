 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 01:31:37]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CLBLKREP\
 git add "clblkrep.s"
 git add "clblkrep.zip"
 git add "clblkrep_readme.md"
 git commit -m "Update clblkrep directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CLBLKREP
