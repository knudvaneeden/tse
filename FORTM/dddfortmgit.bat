 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 00:59:57]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\FORTM\
 git add asgnum.s
 git add blines.s
 git add comments.s
 git add fortm.zip
 git add fortm_readme.md
 git add indent.s
 git add inuse.s
 git add ljlabels.s
 git add nin.s
 git add notlabel.s
 git add readme.!$!
 git add relabel.s
 git add upperc.s
 git commit -m "Update fortm directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/FORTM
