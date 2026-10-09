 @REM version: 1.0.0.0.0 [kn, ri, mo, 31-08-2026 17:03:47]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\BROWSMOD\
 git add browsmod.s
 git add browsmod_readme.md
 git add browsmod.zip
 git commit -m "Update browsmod directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/BROWSMOD
