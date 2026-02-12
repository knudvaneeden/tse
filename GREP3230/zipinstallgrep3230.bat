REM
REM compile relevant .s and .si files to .mac
REM
sc32 dialog.si
sc32 dialogp.s
sc32 gethelp.si
sc32 grep3230.s
sc32 grepdlg.si
sc32 scpaint.si
REM
sc32 grep.s
REM
REM ===
REM
REM refresh the zip file
REM
del grep3230_knud.zip
REM
REM ===
REM
REM zipping all these files
REM
REM ===
REM
pkzipc -add grep3230_knud.zip dialog.si
pkzipc -add grep3230_knud.zip dialog.mac
REM
pkzipc -add grep3230_knud.zip dialogp.s
pkzipc -add grep3230_knud.zip dialogp.mac
REM
pkzipc -add grep3230_knud.zip gethelp.si
pkzipc -add grep3230_knud.zip gethelp.mac
REM
pkzipc -add grep3230_knud.zip grep.hlp
REM
pkzipc -add grep3230_knud.zip grep3230.s
pkzipc -add grep3230_knud.zip grep3230.mac
REM
pkzipc -add grep3230_knud.zip grep.txt
REM
pkzipc -add grep3230_knud.zip grep.s
pkzipc -add grep3230_knud.zip grep.mac
REM
pkzipc -add grep3230_knud.zip grepdlg.d
pkzipc -add grep3230_knud.zip grepdlg.dlg
pkzipc -add grep3230_knud.zip grepdlg.si
REM
pkzipc -add grep3230_knud.zip guiinc.inc
REM
pkzipc -add grep3230_knud.zip helphelp.s
pkzipc -add grep3230_knud.zip helphelp.mac
REM
pkzipc -add grep3230_knud.zip scpaint.si
REM
pkzipc -add grep3230_knud.zip zipgrep3230.bat
REM
REM view the result in the zip file
REM
echo zipview grep3230_knud.zip
REM
REM after running the installation batch file, load this file in your TSE and run it
REM
pkzipc -extract -dir grep3230_knud.zip
REM
@ECHO "zipview grep3230_knud.zip"
REM
@ECHO "To install"
@ECHO "1. -Store all the files in this directory in some temporary directory"
@ECHO "2. -Change directory to that temporary directory"
@ECHO "3. -Then run this batch file"
@ECHO "4. -That will recompile all or only the relevant .s and .si files and collect the necessary other files"
@ECHO "5. -Then the resulting .zip file contains all the necessary files to run it on your computer"
@ECHO "6. -Then unzip that resulting .zip file in some new arbitrary directory"
@ECHO "7. -Then run in TSE"
@ECHO "8. -execute this macro (you must supply the full path to this macro)"
@ECHO grep.mac
