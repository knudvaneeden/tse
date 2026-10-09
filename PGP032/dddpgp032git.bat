 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 14:43:00]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PGP032\
 git add pgp.inf
 git add pgp.qem
 git add pgp.s
 git add pgp032.ini
 git add pgp032.zip
 git add pgp0321.0.0.0.0.zip
 git add pgp032_readme.md
 git commit -m "Update pgp032 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PGP032
