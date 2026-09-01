 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 01:05:51]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CALC_SRC\
 git add acalc.s
 git add build_fplow.bat
 git add calc.doc
 git add calc.inc
 git add calc.s
 git add calc_src.zip
 git add calc_src_readme.md
 git add dddcalc_srcgit.bat
 git add fpcalc.s
 git add fplow.c
 git add fplow.def
 git add fplow.dll
 git add fp_min.s
 git add fp_min_dll.s
 git add icalc.hlp
 git add icalc.s
 git commit -m "Update calc_src directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CALC_SRC
