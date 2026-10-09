 @REM version: 1.0.0.0.0 [kn, ri, th, 10-09-2026 12:13:54]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\GC_WSUI\
 git add file_id.diz
 git add gc_wsui.zip
 git add gc_wsui_readme.md
 git add tse4gui.cfg
 git add tse4gui.ui
 git commit -m "Update gc_wsui directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/GC_WSUI
