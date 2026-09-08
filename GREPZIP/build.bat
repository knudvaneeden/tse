@echo off
setlocal
rem GREPZIP 1.0.0.0.7 - compile the TSE SAL macro.
sc32 grepzip.s
if errorlevel 1 goto build_error
echo.
echo Built GREPZIP.MAC successfully.
goto end
:build_error
echo.
echo Build failed. Review the SAL compiler messages above.
:end
endlocal
