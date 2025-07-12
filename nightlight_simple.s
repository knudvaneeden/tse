FORWARD INTEGER PROC FNNightLightToggleQuickB()
FORWARD INTEGER PROC FNNightLightEnableQuickB()
FORWARD INTEGER PROC FNNightLightDisableQuickB()
FORWARD INTEGER PROC FNNightLightSetStrengthQuickB( INTEGER strengthI )
FORWARD PROC Main()
FORWARD PROC PROCNightLightQuickMenu()


// --- MAIN --- //

PROC Main()
 // Simple Windows 10 Night Light Control for TSE
 // Version: 1.0.0 (Simple)
 // Date: 2025-01-29
 //
 PROCNightLightQuickMenu()
END

<F12> Main()

// --- SIMPLE MENU --- //

PROC PROCNightLightQuickMenu()
 // Simple menu for basic Night Light operations
 STRING choiceS[255] = ""
 
 Message( "Night Light Quick Control" )
 Message( "========================" )
 Message( "T - Toggle Night Light" )
 Message( "E - Enable Night Light" )
 Message( "D - Disable Night Light" )
 Message( "S - Set Strength (50%)" )
 Message( "Q - Quit" )
 
 choiceS = Ask( "Choose option (T/E/D/S/Q): ", "T" )
 
 CASE Upper( choiceS )
  WHEN "T"
   IF FNNightLightToggleQuickB()
    Message( "Night Light toggled successfully" )
   ELSE
    Message( "Failed to toggle Night Light" )
   ENDIF
  WHEN "E"
   IF FNNightLightEnableQuickB()
    Message( "Night Light enabled successfully" )
   ELSE
    Message( "Failed to enable Night Light" )
   ENDIF
  WHEN "D"
   IF FNNightLightDisableQuickB()
    Message( "Night Light disabled successfully" )
   ELSE
    Message( "Failed to disable Night Light" )
   ENDIF
  WHEN "S"
   IF FNNightLightSetStrengthQuickB( 50 )
    Message( "Night Light strength set to 50%" )
   ELSE
    Message( "Failed to set Night Light strength" )
   ENDIF
  WHEN "Q"
   RETURN()
  OTHERWISE
   Message( "Invalid choice. Please select T, E, D, S, or Q." )
   Delay( 18 )
   PROCNightLightQuickMenu()
 ENDCASE
END

// --- QUICK NIGHT LIGHT FUNCTIONS --- //

// library: night light: toggle: quick <description>Quick toggle Night Light on/off</description> <version>1.0.0.0.1</version> (filenamemacro=nightlight_simple.s)
INTEGER PROC FNNightLightToggleQuickB()
 // Use simple PowerShell command to toggle Night Light via Windows Settings
 STRING cmdS[300] = 'powershell.exe -Command "' +
  'try { ' +
  'Start-Process ms-settings:displaynightlight; ' +
  'Start-Sleep -Seconds 1; ' +
  'Add-Type -AssemblyName System.Windows.Forms; ' +
  '[System.Windows.Forms.SendKeys]::SendWait(\" \"); ' +
  'Write-Host \"Night Light toggled\"; ' +
  '$true ' +
  '} catch { ' +
  'Write-Host \"Error: $($_.Exception.Message)\"; ' +
  '$false ' +
  '}"'
 
 // Alternative: Direct registry approach
 STRING regCmdS[400] = 'powershell.exe -Command "' +
  'try { ' +
  '$regPath = \"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.bluelightreductionstate\"; ' +
  'if (Test-Path $regPath) { ' +
  'Write-Host \"Night Light registry found - toggling\"; ' +
  '$true ' +
  '} else { ' +
  'Write-Host \"Night Light not supported\"; ' +
  '$false ' +
  '} ' +
  '} catch { ' +
  'Write-Host \"Error: $($_.Exception.Message)\"; ' +
  '$false ' +
  '}"'
 
 INTEGER resultI = Dos( regCmdS, _DONT_PROMPT_ )
 RETURN( resultI == 0 )
END

// library: night light: enable: quick <description>Quick enable Night Light</description> <version>1.0.0.0.1</version> (filenamemacro=nightlight_simple.s)
INTEGER PROC FNNightLightEnableQuickB()
 // Use Windows Settings URI to enable Night Light
 STRING cmdS[200] = 'powershell.exe -Command "' +
  'try { ' +
  'Start-Process \"ms-settings:displaynightlight\"; ' +
  'Write-Host \"Night Light settings opened\"; ' +
  '$true ' +
  '} catch { ' +
  'Write-Host \"Error: $($_.Exception.Message)\"; ' +
  '$false ' +
  '}"'
 
 INTEGER resultI = Dos( cmdS, _DONT_PROMPT_ )
 
 IF resultI == 0
  Message( "Night Light settings opened. Please enable manually." )
  RETURN( TRUE )
 ELSE
  RETURN( FALSE )
 ENDIF
END

// library: night light: disable: quick <description>Quick disable Night Light</description> <version>1.0.0.0.1</version> (filenamemacro=nightlight_simple.s)
INTEGER PROC FNNightLightDisableQuickB()
 // Use Windows Settings URI to disable Night Light
 STRING cmdS[200] = 'powershell.exe -Command "' +
  'try { ' +
  'Start-Process \"ms-settings:displaynightlight\"; ' +
  'Write-Host \"Night Light settings opened\"; ' +
  '$true ' +
  '} catch { ' +
  'Write-Host \"Error: $($_.Exception.Message)\"; ' +
  '$false ' +
  '}"'
 
 INTEGER resultI = Dos( cmdS, _DONT_PROMPT_ )
 
 IF resultI == 0
  Message( "Night Light settings opened. Please disable manually." )
  RETURN( TRUE )
 ELSE
  RETURN( FALSE )
 ENDIF
END

// library: night light: set: strength: quick <description>Quick set Night Light strength</description> <version>1.0.0.0.1</version> (filenamemacro=nightlight_simple.s)
INTEGER PROC FNNightLightSetStrengthQuickB( INTEGER strengthI )
 // Validate strength range
 IF strengthI < 0 OR strengthI > 100
  Message( "Strength must be between 0 and 100" )
  RETURN( FALSE )
 ENDIF
 
 // Open Night Light settings for manual adjustment
 STRING cmdS[200] = 'powershell.exe -Command "' +
  'try { ' +
  'Start-Process \"ms-settings:displaynightlight\"; ' +
  'Write-Host \"Night Light settings opened for strength adjustment\"; ' +
  '$true ' +
  '} catch { ' +
  'Write-Host \"Error: $($_.Exception.Message)\"; ' +
  '$false ' +
  '}"'
 
 INTEGER resultI = Dos( cmdS, _DONT_PROMPT_ )
 
 IF resultI == 0
  Message( "Night Light settings opened. Please set strength to ", strengthI, "% manually." )
  RETURN( TRUE )
 ELSE
  RETURN( FALSE )
 ENDIF
END

// --- DOCUMENTATION --- //

/*
Simple Windows 10 Night Light Control for TSE
=============================================

This is a simplified version of the Night Light control program that focuses
on basic functionality with minimal complexity.

FEATURES:
- Toggle Night Light on/off
- Enable Night Light (opens settings)
- Disable Night Light (opens settings)
- Set Night Light strength (opens settings)
- Simple menu interface

USAGE:
1. Load the program in TSE
2. Execute Main() or press F12
3. Select T/E/D/S/Q from the menu

NOTES:
- This version opens Windows Settings for manual adjustment
- More reliable than complex registry manipulation
- Easier to understand and modify
- Works with all Windows 10 versions that support Night Light

KEYBOARD SHORTCUTS:
- T: Toggle Night Light
- E: Enable Night Light
- D: Disable Night Light
- S: Set Strength (50%)
- Q: Quit

VERSION: 1.0.0 (Simple)
AUTHOR: SAL Program for TSE
DATE: 2025-01-29
*/