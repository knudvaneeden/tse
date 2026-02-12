@echo off

rem     ----------------------------------------------------------------
rem
rem     Dialogs Un-Installer
rem
rem     Version         v2.10/07.06.01
rem     Copyright       (c) 1996-2001 by DiK
rem
rem     Overview:
rem
rem     This batch file is meant as a tool to quickly get rid
rem     of all the dialog files (past and present)
rem
rem     Usage:
rem
rem     Go to the folder which contains the dialog files and
rem     execute deldlg.bat
rem
rem     History
rem
rem     v2.10/07.06.01  added additional files
rem     v2.02/07.01.99  added additional files
rem     v2.01/02.04.97  added additional files
rem     v2.00/24.10.96  added additional files
rem     v1.22/18.06.96  added additional files
rem     v1.21/29.05.96  added additional files
rem     v1.20/25.03.96  first version
rem
rem     ----------------------------------------------------------------

cls
echo.
echo Dialogs Un-Installer
echo.
echo deletes the TSE dialogs library package in the CURRENT directory.
echo The configuration file (dialog.cfg) will NOT be deleted.
echo.
echo Delete ALL dialog files now? If NO press CTRL-C!
echo.
pause

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 1.00
rem
rem     please note that the dlg100.zip included some subdirectories
rem     if you installed these you must run deldlg multiple times
rem     and manually remove the empty subdirectories
rem
rem     ----------------------------------------------------------------

if exist dlgbuff.d      del dlgbuff.d
if exist dlgfind.d      del dlgfind.d
if exist dlggoto.d      del dlggoto.d
if exist dlghist1.d     del dlghist1.d
if exist dlghist2.d     del dlghist2.d
if exist dlgmcc.d       del dlgmcc.d
if exist dlgopen.d      del dlgopen.d
if exist dlgrcnt.d      del dlgrcnt.d
if exist dlgrplc.d      del dlgrplc.d
if exist testdlg1.d     del testdlg1.d
if exist testdlg2.d     del testdlg2.d
if exist testdlg3.d     del testdlg3.d
if exist file_id.diz    del file_id.diz
if exist dlgbuff.dlg    del dlgbuff.dlg
if exist dlgfind.dlg    del dlgfind.dlg
if exist dlggoto.dlg    del dlggoto.dlg
if exist dlghist.dlg    del dlghist.dlg
if exist dlghist1.dlg   del dlghist1.dlg
if exist dlghist2.dlg   del dlghist2.dlg
if exist dlgmcc.dlg     del dlgmcc.dlg
if exist dlgopen.dlg    del dlgopen.dlg
if exist dlgrcnt.dlg    del dlgrcnt.dlg
if exist dlgrplc.dlg    del dlgrplc.dlg
if exist testdlg1.dlg   del testdlg1.dlg
if exist testdlg2.dlg   del testdlg2.dlg
if exist testdlg3.dlg   del testdlg3.dlg
if exist dialog.doc     del dialog.doc
if exist program.doc    del program.doc
if exist dc.mac         del dc.mac
if exist dialog.mac     del dialog.mac
if exist dlgbuff.mac    del dlgbuff.mac
if exist dlgfind.mac    del dlgfind.mac
if exist dlggoto.mac    del dlggoto.mac
if exist dlghist.mac    del dlghist.mac
if exist dlghisth.mac   del dlghisth.mac
if exist dlgmcc.mac     del dlgmcc.mac
if exist dlgmcch.mac    del dlgmcch.mac
if exist dlgopen.mac    del dlgopen.mac
if exist dlgopenh.mac   del dlgopenh.mac
if exist dlgrcnt.mac    del dlgrcnt.mac
if exist dlgrplc.mac    del dlgrplc.mac
if exist drivelst.mac   del drivelst.mac
if exist hello.mac      del hello.mac
if exist inpbox.mac     del inpbox.mac
if exist msgbox.mac     del msgbox.mac
if exist testdlg1.mac   del testdlg1.mac
if exist testdlg2.mac   del testdlg2.mac
if exist testdlg3.mac   del testdlg3.mac
if exist testib1.mac    del testib1.mac
if exist testmb1.mac    del testmb1.mac
if exist dc.s           del dc.s
if exist dialog.s       del dialog.s
if exist dlgbuff.s      del dlgbuff.s
if exist dlgfind.s      del dlgfind.s
if exist dlggoto.s      del dlggoto.s
if exist dlghist.s      del dlghist.s
if exist dlghisth.s     del dlghisth.s
if exist dlgmcc.s       del dlgmcc.s
if exist dlgmcch.s      del dlgmcch.s
if exist dlgopen.s      del dlgopen.s
if exist dlgopenh.s     del dlgopenh.s
if exist dlgrcnt.s      del dlgrcnt.s
if exist dlgrplc.s      del dlgrplc.s
if exist drivelst.s     del drivelst.s
if exist hello.s        del hello.s
if exist inpbox.s       del inpbox.s
if exist msgbox.s       del msgbox.s
if exist testdlg1.s     del testdlg1.s
if exist testdlg2.s     del testdlg2.s
if exist testdlg3.s     del testdlg3.s
if exist testib1.s      del testib1.s
if exist testmb1.s      del testmb1.s
if exist dialog.src     del dialog.src
if exist dlgbuff.src    del dlgbuff.src
if exist dlgclr.src     del dlgclr.src
if exist dlgfind.src    del dlgfind.src
if exist dlggoto.src    del dlggoto.src
if exist dlghist1.src   del dlghist1.src
if exist dlghist2.src   del dlghist2.src
if exist dlgmcc.src     del dlgmcc.src
if exist dlgopen.src    del dlgopen.src
if exist dlgrcnt.src    del dlgrcnt.src
if exist dlgrplc.src    del dlgrplc.src
if exist msgbox.src     del msgbox.src
if exist testdlg1.src   del testdlg1.src
if exist testdlg2.src   del testdlg2.src
if exist testdlg3.src   del testdlg3.src
if exist dlg.ui         del dlg.ui

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 1.10          (additional filesÿ)
rem
rem     ----------------------------------------------------------------

if exist dlgascii.d     del dlgascii.d
if exist dlgsetu1.d     del dlgsetu1.d
if exist dlgsetu2.d     del dlgsetu2.d
if exist dlgascii.dlg   del dlgascii.dlg
if exist dlgsetu1.dlg   del dlgsetu1.dlg
if exist dlgsetu2.dlg   del dlgsetu2.dlg
if exist dlgascii.mac   del dlgascii.mac
if exist dlgsetup.mac   del dlgsetup.mac
if exist dlgascii.s     del dlgascii.s
if exist dlgsetup.s     del dlgsetup.s
if exist dlgascii.src   del dlgascii.src
if exist dlgsetu1.src   del dlgsetu1.src
if exist dlgsetu2.src   del dlgsetu2.src

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 1.20          (additional filesÿ)
rem
rem     ----------------------------------------------------------------

if exist dlgfnddo.d     del dlgfnddo.d
if exist dlghist3.d     del dlghist3.d
if exist dlgfnddo.dlg   del dlgfnddo.dlg
if exist dlghist3.dlg   del dlghist3.dlg
if exist dd.mac         del dd.mac
if exist de.mac         del de.mac
if exist dlgfnddo.mac   del dlgfnddo.mac
if exist uptdecmp.mac   del uptdecmp.mac
if exist dd.s           del dd.s
if exist de.s           del de.s
if exist dlgfnddo.s     del dlgfnddo.s
if exist uptdecmp.s     del uptdecmp.s
if exist dialog.si      del dialog.si
if exist dlgascii.si    del dlgascii.si
if exist dlgbuff.si     del dlgbuff.si
if exist dlgclr.si      del dlgclr.si
if exist dlgfind.si     del dlgfind.si
if exist dlgfnddo.si    del dlgfnddo.si
if exist dlggoto.si     del dlggoto.si
if exist dlghist1.si    del dlghist1.si
if exist dlghist2.si    del dlghist2.si
if exist dlghist3.si    del dlghist3.si
if exist dlgmcc.si      del dlgmcc.si
if exist dlgopen.si     del dlgopen.si
if exist dlgrcnt.si     del dlgrcnt.si
if exist dlgrplc.si     del dlgrplc.si
if exist dlgrun.si      del dlgrun.si
if exist dlgruns.si     del dlgruns.si
if exist dlgsetu1.si    del dlgsetu1.si
if exist dlgsetu2.si    del dlgsetu2.si
if exist dlgver.si      del dlgver.si
if exist msgbox.si      del msgbox.si
if exist testdlg1.si    del testdlg1.si
if exist testdlg2.si    del testdlg2.si
if exist testdlg3.si    del testdlg3.si

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 1.21          (additional filesÿ)
rem
rem     ----------------------------------------------------------------

if exist readme.121     del readme.121
if exist dlgwopen.d     del dlgwopen.d
if exist dlgwopn1.d     del dlgwopn1.d
if exist dlgwopen.dlg   del dlgwopen.dlg
if exist dlgwopn1.dlg   del dlgwopn1.dlg
if exist dlgwopen.doc   del dlgwopen.doc
if exist dlgwopen.mac   del dlgwopen.mac
if exist dlgwopen.s     del dlgwopen.s
if exist dlgwopen.si    del dlgwopen.si
if exist dlgwopn1.si    del dlgwopn1.si

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 1.30          (additional filesÿ)
rem     (various "betas" for "released" version 2.00)
rem
rem     ----------------------------------------------------------------

if exist readme.130     del readme.130
if exist dlgcomp.d      del dlgcomp.d
if exist dlgcomp.dlg    del dlgcomp.dlg
if exist dlgcomp.mac    del dlgcomp.mac
if exist dlgcomp1.mac   del dlgcomp1.mac
if exist dlgcomp.s      del dlgcomp.s
if exist dlgcomp1.s     del dlgcomp1.s
if exist dlgcomp.si     del dlgcomp.si
if exist dlgtoken.si    del dlgtoken.si

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 2.00          (additional filesÿ)
rem
rem     ----------------------------------------------------------------

if exist instdlg.bat    del instdlg.bat
if exist tsecomp.bat    del tsecomp.bat
if exist listfile.asm   del listfile.asm
if exist listfile.bin   del listfile.bin
if exist dlgop16a.d     del dlgop16a.d
if exist dlgop32a.d     del dlgop32a.d
if exist dlgop32b.d     del dlgop32b.d
if exist dlgop16a.dlg   del dlgop16a.dlg
if exist dlgop32a.dlg   del dlgop32a.dlg
if exist dlgop32b.dlg   del dlgop32b.dlg
if exist dialogp.mac    del dialogp.mac
if exist dbgtrace.mac   del dbgtrace.mac
if exist dlgcompx.mac   del dlgcompx.mac
if exist dlgop16d.mac   del dlgop16d.mac
if exist dialogp.s      del dialogp.s
if exist dbgtrace.s     del dbgtrace.s
if exist dlgcompx.s     del dlgcompx.s
if exist dlgop16d.s     del dlgop16d.s
if exist dlgopen.s      del dlgopen.s
if exist dlgop16a.si    del dlgop16a.si
if exist dlgop32a.si    del dlgop32a.si
if exist dlgop32b.si    del dlgop32b.si
if exist scop16w.si     del scop16w.si
if exist scop32w.si     del scop32w.si
if exist scoptyp1.si    del scoptyp1.si
if exist scoptyp2.si    del scoptyp2.si
if exist scpaint.si     del scpaint.si
if exist scrun.si       del scrun.si
if exist scruns.si      del scruns.si
if exist sctoken.si     del sctoken.si
if exist scver.si       del scver.si

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 2.01          (additional filesÿ)
rem
rem     ----------------------------------------------------------------

if exist readme.201     del readme.201
if exist testdlg4.d     del testdlg4.d
if exist testdlg4.dlg   del testdlg4.dlg
if exist testdlg4.s     del testdlg4.s
if exist testdlg4.si    del testdlg4.si

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 2.02          (additional filesÿ)
rem
rem     ----------------------------------------------------------------

if exist dlgvideo.d     del dlgvideo.d
if exist dlgvideo.dlg   del dlgvideo.dlg
if exist dlgvideo.mac   del dlgvideo.mac
if exist setvideo.mac   del setvideo.mac
if exist dlgvideo.s     del dlgvideo.s
if exist setvideo.s     del setvideo.s
if exist dlgvideo.si    del dlgvideo.si

rem     ----------------------------------------------------------------
rem
rem     dialogs - version 2.10          (additional filesÿ)
rem
rem     ----------------------------------------------------------------

if exist scwinclp.si  del scwinclp.si
if exist schelp.si    del schelp.si
if exist scgtfldr.si  del scgtfldr.si
if exist getfldr.dpr  del getfldr.dpr
if exist getfldr.dll  del getfldr.dll
if exist dlg30.ui     del dlg30.ui

rem     ----------------------------------------------------------------
rem
rem     finally, commit suicide, but only after asking user
rem
rem     ----------------------------------------------------------------

cls
echo.
echo Dialogs Un-Installer
echo.
echo The Un-Installer can remove itself from the CURRENT directory.
echo.
echo Attention! This WILL generate an error message which is harmless!
echo.
echo Delete Un-Install utility now? If NO press CTRL-C!
echo.
pause

del deldlg.bat

