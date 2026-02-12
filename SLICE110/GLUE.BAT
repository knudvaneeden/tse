@echo off

rem --------------------------------------------------------------------
rem     glues sliced files
rem     Version 1.10                                (Copyright by DiK)
rem --------------------------------------------------------------------

setlocal
unalias *

echo Glue  Version 1.1  Copyright (c) 1998-2000 by DiK

if "%1" == "" goto help_me

set fext=%@ext[%1]
set fname=%@name[%1]

if "%fext" != "001" goto help_me
if "%@path[%1]" != "" goto help_me

if not exist "%1" goto file_must_exist

rem --------------------------------------------------------------------

echo %fname.%fext
copy /qb "%fname.%fext" "%fname"
if %_? != 0 quit

do forever
    set fext=%@instr[2,-3,00%@inc[%fext]]
    if not exist "%fname.%fext" quit
    echo %fname.%fext
    copy /qb "%fname" + "%fname.%fext"
enddo

rem --------------------------------------------------------------------

:file_must_exist
echo.
echo File "%1" not found

quit

rem --------------------------------------------------------------------

:help_me
text

Glue reassembles files which have been split using Slice

syntax:     glue filename.001

notes:      The extension must be 001, since slices usually
            include multiple dots (e.g. foo.zip.001).
            The filename must not include a path, e.g.
            glue only works within the current directory.
endtext
