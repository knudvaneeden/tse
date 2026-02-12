@echo off
if "%1"== ""  goto :no2
if "%1"== "?" goto :help
if "%2"== ""  goto :help
set sstring=%1
set infile=%2
set options=%3
set ts_options=%4
set outfile=%5
set exclude=" .bak .$hp"
:no2

e -eTSGREP

rem cls
goto end

:help
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³ Usage:                                                               ³
echo ³       TSGREP                                                         ³
echo ³       TSGREP searchstring infile                                     ³
echo ³       TSGREP searchstring infile [srch_opts [TSGREP_opts outfile]]   ³
echo ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ
echo ³ If no arguments given, TSGREP prompts for each one.                  ³
echo ³ Searchstring may be any TSE searchstring.                            ³
echo ³      * Use -or- as the 'OR' indicator                                ³
echo ³      * Use -and- as the 'AND' indicator                              ³
echo ³      * Use \- instead of =                                           ³
echo ³      * Use _ instead of space                                        ³
echo ³ Infile may be any valid filespec, wildcards included.                ³
echo ³      Files with '@' in the name are treated as list files.           ³
echo ³      Add + to the end of the filespec for recursive search.          ³
echo ³      List files may be nested to 3 levels; possibly more will work.  ³
echo ³      Use ^ as a separator for multiple filespecs.                    ³
echo ³ Srch_opts may be any TSE search options except b, c, l.              ³
echo ³      * Default options = 'i                                          ³
echo ³ TSGREP_opts control TSGREP operation. See TSGREP.DOC for information.³
echo ³      * Use # in options for suppress line numbers                    ³
echo ³      * Use 1 in options to stop searching each file after 1 match    ³
echo ³ Outfile is optional; default is TSGREP.TMP                           ³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
:end
die!
set sstring=
set infile=
set outfile=
set options=
set ts_options=
set exclude=
