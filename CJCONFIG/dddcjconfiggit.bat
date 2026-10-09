 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 00:55:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CJCONFIG\
 git add "backspac.s"
 git add "cjconfig.nts"
 git add "cjconfig.zip"
 git add "cjconfig_readme.md"
 git add "fulljust.s"
 git add "mmatch.s"
 git add "parafind.s"
 git commit -m "Update cjconfig directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CJCONFIG
