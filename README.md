# Windows 10 Night Light Control for The SemWare Editor Professional

A comprehensive SAL (SemWare Application Language) program that provides control over Windows 10's Night Light feature directly from within The SemWare Editor Professional.

## Features

- **Check Night Light Support**: Verify if Night Light is supported on the current system
- **Enable/Disable Night Light**: Turn Night Light on or off
- **Toggle Night Light**: Switch Night Light state (on/off)
- **Set Night Light Strength**: Control warmth level (0-100%)
- **Set Color Temperature**: Direct temperature control (1200-6500K)
- **Get Current Strength**: Check current Night Light strength
- **User-friendly Menu Interface**: Interactive menu system for all operations

## Files

- `nightlight.s` - Main SAL program with full functionality
- `nightlight_simple.s` - Simplified version with basic toggle functionality
- `README.md` - This documentation file

## Installation

1. Copy `nightlight.s` to your TSE macro directory
2. Load the program in The SemWare Editor Professional
3. Execute the program by pressing `F12` or calling `Main()`

## Usage

### Using the Menu Interface

1. Run the program with `F12` or `Main()`
2. Select from the menu options:
   - **1**: Check Night Light Status
   - **2**: Toggle Night Light On/Off
   - **3**: Enable Night Light
   - **4**: Disable Night Light
   - **5**: Set Night Light Strength (0-100%)
   - **6**: Get Current Strength
   - **7**: Set Color Temperature (1200-6500K)
   - **8**: Check Support
   - **9**: Exit

### Using Individual Functions

You can also call specific functions directly:

```sal
// Check if Night Light is supported
Message( FNNightLightCheckSupportedB() )

// Toggle Night Light
Message( FNNightLightToggleB() )

// Enable Night Light
Message( FNNightLightEnableB() )

// Disable Night Light
Message( FNNightLightDisableB() )

// Set strength to 75%
Message( FNNightLightSetStrengthB( 75 ) )

// Get current strength
Message( FNNightLightGetStrengthI() )

// Set color temperature to 3000K
Message( FNNightLightSetTemperatureB( 3000 ) )
```

## Technical Details

### Registry Keys Used

The program manipulates the following Windows registry keys:

- **State**: `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.bluelightreductionstate`
- **Settings**: `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.settings`

### Implementation Method

The program uses PowerShell commands executed via the SAL `Dos()` function to:
- Read and write registry values
- Execute Windows API calls
- Check system support for Night Light

### Color Temperature Scale

- **0% Strength** = 6500K (coolest, most blue light)
- **100% Strength** = 1200K (warmest, least blue light)
- **Default** = 3000K (approximately 50% strength)

## Requirements

- **Windows 10 Professional** (Creators Update or later)
- **The SemWare Editor Professional** (TSE)
- **PowerShell** execution policy allows script execution
- **Administrator privileges** may be required for registry access

## Compatibility

| Windows Version | Status |
|----------------|---------|
| Windows 10 Creators Update (1703) | ✅ Supported |
| Windows 10 Fall Creators Update (1709) | ✅ Supported |
| Windows 10 April 2018 Update (1803) | ✅ Supported |
| Windows 10 October 2018 Update (1809) | ✅ Supported |
| Windows 10 May 2019 Update (1903) | ✅ Supported |
| Windows 10 November 2019 Update (1909) | ✅ Supported |
| Windows 10 May 2020 Update (2004) | ✅ Supported |
| Windows 10 October 2020 Update (20H2) | ✅ Supported |
| Windows 10 May 2021 Update (21H1) | ✅ Supported |
| Windows 10 November 2021 Update (21H2) | ✅ Supported |
| Windows 11 | ✅ Supported |

## Troubleshooting

### Common Issues

1. **"Night Light not supported"**
   - Ensure you're running Windows 10 Creators Update or later
   - Check if your display driver supports Night Light
   - Some DisplayLink or Basic Display drivers don't support Night Light

2. **Registry access denied**
   - Run TSE as Administrator
   - Check PowerShell execution policy: `Get-ExecutionPolicy`
   - Set execution policy if needed: `Set-ExecutionPolicy RemoteSigned`

3. **PowerShell command fails**
   - Ensure PowerShell is installed and accessible
   - Check if Windows Management Framework is up to date
   - Verify registry keys exist manually using `regedit`

### Debugging

Enable debug mode by modifying the PowerShell commands to include verbose output:

```sal
STRING cmdS[500] = 'powershell.exe -Command "' +
  'try { ' +
  'Write-Host \"Debug: Starting Night Light operation\"; ' +
  '# your command here ' +
  '} catch { ' +
  'Write-Host \"Error: $($_.Exception.Message)\"; ' +
  'Write-Host \"Debug: Full error details: $($_.Exception.ToString())\"; ' +
  '}"'
```

## Examples

### Basic Usage Example

```sal
PROC TestNightLight()
 // Check support first
 IF FNNightLightCheckSupportedB()
  Message( "Night Light is supported" )
  
  // Toggle Night Light
  IF FNNightLightToggleB()
   Message( "Night Light toggled successfully" )
  ELSE
   Message( "Failed to toggle Night Light" )
  ENDIF
  
  // Set to 75% strength
  IF FNNightLightSetStrengthB( 75 )
   Message( "Night Light strength set to 75%" )
  ENDIF
  
  // Display current strength
  Message( "Current strength: ", FNNightLightGetStrengthI(), "%" )
 ELSE
  Message( "Night Light is not supported on this system" )
 ENDIF
END
```

### Advanced Usage Example

```sal
PROC AutoNightLight()
 // Automatically configure Night Light based on time of day
 INTEGER hourI = Val( GetTimeStr( 1 ) )
 
 IF hourI >= 18 OR hourI <= 6
  // Evening/night time - enable with high strength
  FNNightLightEnableB()
  FNNightLightSetStrengthB( 80 )
  Message( "Night Light enabled for evening/night" )
 ELSE
  // Daytime - disable
  FNNightLightDisableB()
  Message( "Night Light disabled for daytime" )
 ENDIF
END
```

## License

This program is provided as-is for educational and practical use with The SemWare Editor Professional. Feel free to modify and distribute according to your needs.

## Contributing

To contribute improvements:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with detailed description

## Version History

- **1.0.0** (2025-01-29)
  - Initial release
  - Full menu interface
  - Support for all Night Light operations
  - Comprehensive error handling
  - Registry manipulation via PowerShell

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Verify your Windows version compatibility
3. Test with the simple version first
4. Review TSE documentation for SAL programming

## References

- [The SemWare Editor Professional Documentation](http://www.semware.com)
- [Windows 10 Night Light Technical Details](https://github.com/nathanbabcock/nightlight-cli)
- [SAL Programming Language Reference](https://rosettacode.org/wiki/Category:TSE_SAL)
- [Windows Registry Night Light Keys](https://superuser.com/a/1209192)