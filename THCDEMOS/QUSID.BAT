@echo off
:       QUSID   Query USA_LOCS.TXT file to find LOCATIONS by LOC_ID only
set DrvLtr=R:\
colormsg -f c:\rtp\usahead
if x%3==x goto continue
colormsg " This version is limited to two arguments "
goto noargs

:continue
if x%1==x goto noargs
if exist c:\rtp\usa_locs.txt set DrvLtr=c:\rtp\
xgrep -y %1 %DrvLtr%usa_locs.txt>junk
match -h2 -@1,4 -q %1 junk
: delete next line if you get an extra blank line after the results
: the echo is needed for Windows 98, but not for Win2K or XP
echo 
goto exit

:noargs
colormsg -f c:\rtp\qusid.hlp

:exit
if exist junk. del junk.
