@rem ** BIN file generator **
@if "%1"=="" goto end
tasm %1
tlink %1
exe2bin %1
@del %1.exe
@del %1.obj
@del %1.map
@del %1.bak
:end
