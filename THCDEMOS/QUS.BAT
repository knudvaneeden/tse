@echo off
:       QUS     Query USA_LOCS.TXT file to find LOCATIONS with one or two args
set DrvLtr=R:\
colormsg -f c:\rtp\usahead
if x%3==x goto continue
colormsg " This version is limited to two arguments "
goto noargs

:continue
if x%1==x goto noargs
if exist c:\rtp\usa_locs.txt set DrvLtr=C:\RTP\
xgrep -y %1 %DrvLtr%usa_locs.txt>junk
if NOT x%2==x shift
match -h2 -q %1 junk
: delete next line if you get an extra blank line after the results
: the echo is needed for Windows 98, but not for Win2K or XP
echo 
goto exit

:noargs
colormsg -f c:\rtp\qus.hlp

:exit
if exist junk. del junk.
