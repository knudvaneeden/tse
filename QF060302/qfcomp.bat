@ECHO OFF
cls
echo+
echo+
echo Quiet Flight Batch Compile
echo+
echo Ignore compiler "Notes" which identify functions that are
echo defined but never used.  Some small functions are included
echo in .INC (include) files and pulled in by several macros.  For
echo simplicity, not all the functions are used by all the macros
echo which include the .INC file.
echo+
Echo Also, SEMWARE's SAL COMPILER (SC32.EXE) must be available in this
echo directory or in your path.
echo+
pause
:compile
if exist qflog.err del qflog.err
FOR %%x IN (QF*.s) DO SC32 %%x>>qflog.err
echo+
echo+
echo+
echo Errors from the compile process can be found in QFLOG.ERR
echo+
echo+
pause
IF NOT .%QFPATH%==. goto showenv
echo+
echo Please make sure to set your QFPATH in your autoexec.bat file.
echo+
echo+
echo Example, edit autoexec.bat, then add this line:
echo SET QFPATH=[Directory name]
echo+
echo In place of [Directory name], place your directory where you have
echo stored the QF files.  If you've set up QF files in the C:\TSE
echo sub-directory, then the line would look like this:
echo SET QFPATH=C:\TSE
echo+
echo+
echo+
goto out
:showenv
echo+
echo Please verify your current QFPATH environment variable is correctly
echo set to %QFPATH%.
echo+
echo This should point to the sub-directory where your Quiet Flight files
echo have been stored.
echo+
echo+
:out
pause
:abort
