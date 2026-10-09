 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 23:18:49]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\DECOMP40\
 git add decomp.doc
 git add decomp.s
 git add decomp.si
 git add decomp40.zip
 git add decomp40_readme.md
 git add editkbd.s
 git add file_id.diz
 git add keytable.001
 git add keytable.049
 git add keytable.dat
 git add recomp.s
 git commit -m "Update decomp40 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/DECOMP40
