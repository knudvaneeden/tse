@REM 1. Download and unzip all these TSE macros
@REM
@REM     https://github.com/knudvaneeden/ddd/archive/refs/heads/TRUNK.zip
@REM
@REM 2. You have to replace the path to your TSE sc32.exe to that on your system
@REM
@REM 3. Then put this .bat file in the root directory of your unzipped download file and run it
@REM
@REM 4. It will then automatically recompile all .s and .si in all the TSE macros for your current TSE version (e.g. 4.48 or higher)
@REM
for /R %%f in (*.s) DO f:\wordproc\tse32_v44200\sc32.exe %%f
@REM
for /R %%f in (*.si) DO f:\wordproc\tse32_v44200\sc32.exe %%f
