@REM version: 1.0.0.0.0 [kn, ri, sa, 29-08-2026 17:50:47]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\AFTROCR\
git add aftrocr.s
git add aftrocr_readme.md
git add 2wrdlist.s
git add 2wrdlist.wrd
git add aftrocr.ini
git add aftrocr.zip
git add file_id.diz
git add fubookdu.s
git add fubookdu.s
git add goodcase.s
git add ocr.lst
git add ocr_bl.s
git add readme.txt
git add sort.s
git add aftrocr_1.0.0.0.0.zip
git commit -m "Update aftrocr directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/AFTROCR
