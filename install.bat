@echo off
echo.
echo Windows 10 Night Light Control for TSE - Installation
echo =====================================================
echo.

:: Check if TSE is installed
if exist "C:\Program Files\TSE" (
    set TSE_PATH=C:\Program Files\TSE
    echo TSE found at: %TSE_PATH%
) else if exist "C:\Program Files (x86)\TSE" (
    set TSE_PATH=C:\Program Files (x86)\TSE
    echo TSE found at: %TSE_PATH%
) else (
    echo TSE installation not found in standard locations.
    echo Please specify the TSE installation directory:
    set /p TSE_PATH=TSE Path: 
)

:: Check if the path exists
if not exist "%TSE_PATH%" (
    echo Error: TSE path does not exist: %TSE_PATH%
    pause
    exit /b 1
)

:: Create macro directory if it doesn't exist
if not exist "%TSE_PATH%\mac" (
    mkdir "%TSE_PATH%\mac"
    echo Created macro directory: %TSE_PATH%\mac
)

:: Copy the SAL files
echo.
echo Copying SAL files to TSE macro directory...

if exist "nightlight.s" (
    copy "nightlight.s" "%TSE_PATH%\mac\"
    echo Copied nightlight.s
) else (
    echo Warning: nightlight.s not found in current directory
)

if exist "nightlight_simple.s" (
    copy "nightlight_simple.s" "%TSE_PATH%\mac\"
    echo Copied nightlight_simple.s
) else (
    echo Warning: nightlight_simple.s not found in current directory
)

:: Create a shortcut or key binding instruction
echo.
echo Installation complete!
echo.
echo To use the Night Light control:
echo.
echo 1. Open The SemWare Editor Professional (TSE)
echo 2. Load the macro file:
echo    - Press Alt+M to open the Macro menu
echo    - Select "Load Macro..."
echo    - Choose "nightlight.s" or "nightlight_simple.s"
echo 3. Execute the macro:
echo    - Press F12 to run the main function
echo    - Or type "Main()" in the command line
echo.
echo Alternatively, you can create a key binding:
echo 1. Press Alt+O for Options menu
echo 2. Select "Full Configuration"
echo 3. Go to "Key Assignments"
echo 4. Assign a key to "ExecMacro('nightlight')"
echo.
echo Files installed to: %TSE_PATH%\mac\
echo.

:: Check PowerShell execution policy
echo Checking PowerShell execution policy...
powershell.exe -Command "Get-ExecutionPolicy" > temp_policy.txt 2>&1
set /p POLICY=<temp_policy.txt
del temp_policy.txt 2>nul

echo Current PowerShell execution policy: %POLICY%

if /i "%POLICY%"=="Restricted" (
    echo.
    echo WARNING: PowerShell execution policy is Restricted.
    echo This may prevent the Night Light control from working properly.
    echo.
    echo To fix this, run PowerShell as Administrator and execute:
    echo Set-ExecutionPolicy RemoteSigned
    echo.
    echo Or run this batch file as Administrator to fix it automatically.
    echo.
    choice /C YN /M "Would you like to fix the PowerShell execution policy now? (Requires Administrator privileges)"
    if errorlevel 2 goto :skip_policy
    if errorlevel 1 goto :fix_policy
    
    :fix_policy
    echo Attempting to set PowerShell execution policy...
    powershell.exe -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" 2>nul
    if %errorlevel% equ 0 (
        echo PowerShell execution policy updated successfully.
    ) else (
        echo Failed to update PowerShell execution policy.
        echo Please run this command manually as Administrator:
        echo Set-ExecutionPolicy RemoteSigned
    )
    
    :skip_policy
)

echo.
echo Installation and setup complete!
echo.
echo For more information, see README.md
echo.
pause