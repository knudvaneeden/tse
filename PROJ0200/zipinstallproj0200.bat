REM
REM compile all .s and .si files to .mac
REM
sc32 proj.si
sc32 pjfile.si
sc32 gethelp.si
sc32 helphelp.s
REM
REM ===
REM
REM refresh the zip file
REM
del proj0200_knud.zip
REM
REM ===
REM
REM zipping all these files
REM
pkzipc -add -dir proj0200_knud.zip *.*
REM
REM view the result in the zip file
REM
@ECHO "zipview proj0200_knud.zip"
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
@ECHO proj.mac -m
