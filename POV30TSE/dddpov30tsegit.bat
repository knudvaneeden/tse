 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 21:01:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\POV30TSE\
 git add pov30tse.ini
 git add pov30tse.zip
 git add pov30tse1.0.0.0.0.zip
 git add pov30tse_readme.md
 git add povray.txt
 git commit -m "Update pov30tse directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/POV30TSE
