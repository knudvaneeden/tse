@REM version: 1.0.0.0.0 [kn, ri, we, 09-09-2026 20:28:10]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\BH_WHELP\
 git add bh.c
 git add bh.exe
 git add bh.ini
 git add bh.mac
 git add bh.s
 git add bh_launch.html
 git add bh_portable_1.0.0.0.13.zip
 git add bh_whelp.zip
 git add bh_whelp_readme.md
 git add build.bat
 git add build_helpdeco_borland_NOT_RECOMMENDED.bat
 git add compat.c
 git add compat.h
 git add convert_win32.bat
 git add helpdec1.c
 git add helpdeco.c
 git add helpdeco.exe
 git add helpdeco.h
 git add helper.h
 git add hlp2html.c
 git add hlp2html.exe
 git add rtf2html.c
 git add rtf2html.exe
git commit -m "Update bh_whelp directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/BH_WHELP
