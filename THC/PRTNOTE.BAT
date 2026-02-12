:PRT_NOTE - T/H/C Query NOTE file and PRINT the notes on one or more subjects
@echo off
:start
if x%1==x goto done
ppm -rq %1 c:\notefile>prn
@echo end of "%1">prn
@echo .
shift
goto start
:done
ff
