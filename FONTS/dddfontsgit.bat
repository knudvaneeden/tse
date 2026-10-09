 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 00:48:01]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FONTS\
 git add fixedsysoem14.fon
 git add fonts.zip
 git add fonts_readme.md
 git add kourier.fon
 git add ksans.fon
 git add sprog5x8.fon
 git add sprog5x9.fon
 git add sprog6x8.fon
 git add sprog6x9.fon
 git add sprog8x8.fon
 git commit -m "Update fonts directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FONTS
