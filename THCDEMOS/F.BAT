@echo off
: F     - Query Facility Description file by Bill Hutchison  4/25/96, 8/17/98
set DrvLtr=R:\
if exist c:\rtp\fsep.fil set DrvLtr=c:\rtp\
if x%1 == x   goto syntax
if x%1 == x/? goto syntax
if x%1 == x-? goto syntax
if x%1 == x-a goto show
if x%1 == x-A goto show

if x%1 == x goto done
:       cls
ppm -q1 %1 %DrvLtr%fsep.fil
goto done

:show
ty %DrvLtr%fsep.fil
goto done

:syntax
colormsg -f c:\rtp\f.hlp

:done
