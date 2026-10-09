F:
cd /d F:\BBC\TAAL\PROJ0200\
dir
del F:\BBC\TAAL\PROJ0200\*.*
deltreey CTAGSEXAMPLES
deltreey PJ
deltreey SRC
cd /d F:\BBC\TAAL\PROJ0200\
copy C:\Users\knud_\Downloads\proj02001.0.0.0.%1.zip
dir
cd /d F:\BBC\TAAL\PROJ0200\
pku F:\BBC\TAAL\PROJ0200\proj02001.0.0.0.%1.zip
cd /d F:\BBC\TAAL\PROJ0200\
build.bat F:\WORDPROC\tse32_v45024\sc32.exe
@PAUSE TSE g32.exe will be closed now. Please close open files first if applicable.
pkfg32
t -e F:\BBC\TAAL\PROJ0200\projstart.mac
