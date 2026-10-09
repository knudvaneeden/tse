 @REM version: 1.0.0.0.0 [kn, ri, tu, 15-09-2026 00:51:02]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\LLIST_32\
 git add llist_32.zip
 git add loadlist.s
 git add llist_32_readme.md
 git commit -m "Update llist_32 directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/LLIST_32
