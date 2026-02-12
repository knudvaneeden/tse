@echo off

rem --------------------------------------------------------------------
rem     split large files into smaller pieces
rem     version 1.10                                (Copyright by DiK)
rem --------------------------------------------------------------------

setlocal
unalias *

echo Slice  Version 1.1  Copyright (c) 1998-2000 by DiK

if "%1" == "" goto help_me

if not exist "%1" goto file_must_exist

set slice_argument="%1"
call e32 -eslice

quit

rem --------------------------------------------------------------------

:file_must_exist
echo.
echo File "%1" not found

quit

rem --------------------------------------------------------------------

:help_me
text

Slice splits a large file into smaller pieces

syntax:     slice filename

notes:      The actual slicing is done by a TSE Pro-32 macro.
            The macro asks for the size of the slices using a menu.
            Individual slices are named by appending a numerical
            extension to the original filename.
endtext
