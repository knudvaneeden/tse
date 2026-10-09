 @REM version: 1.0.0.0.0 [kn, ri, we, 02-09-2026 19:17:30]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CLIST_41\
 git add clist.s
 git add clist2.mac
 git add clist3.mac
 git add clist_41.zip
 git add clist_41_readme.md
 git commit -m "Update clist_41 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CLIST_41
