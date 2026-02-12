REM
REM compile all .s and .si files to .mac
REM
sc32 *.s
sc32 *.si
REM
REM ===
REM
REM refresh the zip file
REM
del grepsemware_knud.zip
REM
REM ===
REM
REM zipping all these files (add and recurse all subdirectories)
REM (remove to enable or add to disable the REM in front of the line of the zip executable command line)
REM
REM if using PKWare pkzipc.exe (commercial, default) / https://www.pkware.com/zip/products/pkzip
pkzipc -add -dir grepsemware_knud.zip *.*
REM
REM if using Winzip (commercial) / https://www.winzip.com/en/pages/download/winzip
REM winzip -min -a grepsemware_knud.zip *.*
REM
REM if using 7z (free download) / https://www.7-zip.org/download.html
REM 7z a -r grepsemware_knud.zip *.*
REM
REM if using rar (free download) / https://www.rarlab.com/download.htm
REM rar a r grepsemware_knud.zip *.*
REM
REM if using info-zip (free download) / install zip (at least 3.x) and unzip (at least 6.x) from https://cygwin.com/ / https://sourceforge.net/projects/infozip/ (source code only) / (older) GNUWin32 downloads / http://stahlworks.com/zip
REM zip -r grepsemware_knud.zip *.*
REM
REM ===
REM
REM optional: view the result in the zip file
@ECHO pkzipc -preview grepsemware_knud.zip
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
@ECHO grepsemware.mac
