 @REM version: 1.0.0.0.0 [kn, ri, su, 27-09-2026 18:24:04]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\PRINTER\
 git add printer.ini
 git add printer.s
 git add printer.zip
 git add printer1.0.0.0.0.zip
 git add printer_readme.md
 git commit -m "Update printer directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/PRINTER
