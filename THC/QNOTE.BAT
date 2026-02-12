@echo off
: QNOTE - T/H/C Query NOTE file for notes on one or more subjects
: Make topic specific versions to search note files on specific subjects.
: For example, to search a note file on software reviews, copy QNOTE.BAT to
: QREVIEWS.BAT and then change c:\notefile below to c:\notes\reviews
: @cls
if x%1==x goto showhelp
:start
ppm -rq %1 c:\notefile>junknote
if x%2==x goto show1
shift

:show1
ppm -q %1 junknote
goto done

:showhelp
: Remember to quote each argument which includes a space
colormsg " Usage: QNOTE arg1 [arg2]     to search the NOTE file. "

:done
if exist junknote. del junknote.
