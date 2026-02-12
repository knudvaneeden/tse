@echo off & setlocal enableextensions

cls
echo.
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³ M_TSWTSE.CMD The script that was used to Create a TSWTSE package ³
echo ³ For both the .arc and the .zip format                            ³
echo ³ By Prof. Timo Salmi. Last modified Sun 9-Jan-2005                ³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.

:: Preliminaries
set targdir_=C:\_M
set targname_=TSWTSE10

:: Copy the package indentification file
copy c:\_f\inf\tswtse.diz c:\_m\file_id.diz

:: Delete the potential previous round target files
for %%f in (%targdir_%\%targname_%.???) do del /p %%f

:: Make the (temporary) ARC version for documentation reasons
echo Brief characterization of TSWTSE|pkpak -ac %targdir_%\%targname_% c:\_m\file_id.diz
echo Makefile that built this package|pkpak -ac %targdir_%\%targname_% c:\_f\xtools\m_tswtse.cmd
echo List of programs from T.Salmi   |pkpak -ac %targdir_%\%targname_% c:\_f\inf\tsprog.txt
echo Document of the TSWTSE package  |pkpak -ac %targdir_%\%targname_% c:\_f\inf\tswtseif.txt
echo News accouncemens about TSWTSE  |pkpak -ac %targdir_%\%targname_% c:\_f\inf\tswtsenw.txt
echo Boxdraw characters into ASCII   |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wbox2asc.s
echo Count block lines, words, chars |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wcount.s
echo PKPAK etc date format conversion|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wdatecnv.s
echo Dejustify a right margin        |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wdejusti.s
echo Detab a line or the entire file |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wdetab.s
echo Input date/time, alternate forms|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wdtetim.s
echo Dump block as bin oct dec or hex|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wdump.s
echo Flip one character, incl foreign|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wflipone.s
echo Insert line numbers             |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wline.s
echo Unix email to IBM format, etc   |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wmai2ibm.s
echo Miscellaneous SAL macros        |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wmisc.s
echo Remove blank lines from file/blk|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wnoblank.s
echo Quote messages Usenet news style|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wquotets.s
echo Run programs on the editor text |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wprogs.s
echo Forward search an ascii range   |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wrngefnd.s
echo Rotate text by 13 positions     |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wrot13.s
echo Copy column to row or vice versa|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wrotate.s
echo Relative, abs. or centered ruler|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wruler.s
echo Swap order of text, words/chars |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wswap.s
echo Scroll windows in unison        |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wsynch.s
echo Testbench for new SAL macros    |pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wtest.s
echo Scandinavian 7/8-bit conversions|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wtoasc.s
echo Convert text to upper/lower case|pkpak -ac %targdir_%\%targname_% c:\_e\wtse\mac2\wupcase.s
echo SemWare editor SAL macros>%temp%\m_tswtse.$$$
pkpak -x %targdir_%\%targname_%<%temp%\m_tswtse.$$$
del %temp%\m_tswtse.$$$
pkpak -vc %targdir_%\%targname_%
pkpak -vc %targdir_%\%targname_%|gawk '{printf"%%s\n",$0}'>c:\_m\temp74.prn
pkpak -vc %targdir_%\%targname_%|gawk '{printf"%%s\n",substr($0,1,68)}'>c:\_m\temp68.prn
pkpak -vc %targdir_%\%targname_%|gawk '{printf"%%s\n",substr($0,1,48)}'>c:\_m\temp48.prn
pause

:: Make the public distribution package in ZIP format
echo Brief characterization of TSWTSE|pkzip -aco %targdir_%\%targname_% c:\_m\file_id.diz
echo Makefile that built this package|pkzip -aco %targdir_%\%targname_% c:\_f\xtools\m_tswtse.cmd
echo List of programs from T.Salmi   |pkzip -aco %targdir_%\%targname_% c:\_f\inf\tsprog.txt
echo Document of the TSWTSE package  |pkzip -aco %targdir_%\%targname_% c:\_f\inf\tswtseif.txt
echo News accouncemens about TSWTSE  |pkzip -aco %targdir_%\%targname_% c:\_f\inf\tswtsenw.txt
echo Boxdraw characters into ASCII   |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wbox2asc.s
echo Count block lines, words, chars |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wcount.s
echo PKPAK etc date format conversion|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wdatecnv.s
echo Dejustify a right margin        |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wdejusti.s
echo Detab a line or the entire file |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wdetab.s
echo Input date/time, alternate forms|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wdtetim.s
echo Dump block as bin oct dec or hex|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wdump.s
echo Flip one character, incl foreign|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wflipone.s
echo Insert line numbers             |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wline.s
echo Unix email to IBM format, etc   |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wmai2ibm.s
echo Miscellaneous SAL macros        |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wmisc.s
echo Remove blank lines from file/blk|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wnoblank.s
echo Quote messages Usenet news style|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wquotets.s
echo Run programs on the editor text |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wprogs.s
echo Forward search an ascii range   |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wrngefnd.s
echo Rotate text by 13 positions     |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wrot13.s
echo Copy column to row or vice versa|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wrotate.s
echo Relative, abs. or centered ruler|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wruler.s
echo Swap order of text, words/chars |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wswap.s
echo Scroll windows in unison        |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wsynch.s
echo Testbench for new SAL macros    |pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wtest.s
echo Scandinavian 7/8-bit conversions|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wtoasc.s
echo Convert text to upper/lower case|pkzip -aco %targdir_%\%targname_% c:\_e\wtse\mac2\wupcase.s
echo FTP archives http://garbo.uwasa.fi/ University of Vaasa, Finland|pkzip -zo %targdir_%\%targname_%
pkzip -vc %targdir_%\%targname_%
pause

:: Clean up
:_clean
for %%f in (c:\_m\file_id.diz) do if exist %%f del %%f
endlocal & goto :EOF
