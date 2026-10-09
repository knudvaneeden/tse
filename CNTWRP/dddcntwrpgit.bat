 @REM version: 1.0.0.0.0 [kn, ri, th, 03-09-2026 00:11:19]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CNTWRP\
 git add abspos.s
 git add cntwrp.zip
 git add cntwrp_readme.md
 git add contwrap.doc
 git add contwrap.key
 git add contwrap.s
 git add movepara.s
 git commit -m "Update cntwrp directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CNTWRP
