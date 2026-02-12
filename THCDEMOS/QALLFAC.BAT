@echo off
:       QALLFAC Query FSEP Descr file by Bill Hutchison        4/25/96
set DrvLtr=R:\
if x%1 == x   goto syntax
if x%1 == x/? goto syntax
if x%1 == x-? goto syntax
if x%1 == x-a goto show
if x%1 == x-A goto show

:start
if x%1==x goto done
if exist c:\rtp\fsep.fil set DrvLtr=c:\rtp\
ppm -q %1 %DrvLtr%fsep.fil
goto done

:show
ty %DrvLtr%fsep.fil
goto done

:syntax
colormsg -f c:\rtp\f.hlp
:done
