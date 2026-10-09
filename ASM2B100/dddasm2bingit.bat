@REM version: 1.0.0.0.0 [kn, ri, sa, 29-08-2026 20:00:14]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\ASM2B100\
git add asm2bin.s
git add asm2bin_readme.md
git add asm2bin.doc
git add file_id.diz
git add asm2b100.zip
git add ddd.nasm
git commit -m "Update asm2b100 directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/ASM2B100
