# MR_HACK

Version: 1.0.0.0.0  
Updated: 2026-09-22 17:41:44 CEST  
Original author: Robert Keith Elias, with assistance from Ross Boyd and Carlo Hogeveen  
Package update: OpenAI Codex (GPT-5)

## Description

MR_HACK is a TSE SAL macro for examining the bytes at the current cursor position. After the macro is loaded, it displays a small information window near the right side of the editor. The values are refreshed as the cursor or editor display changes.

The information window interprets the current bytes in several ways:

- File offset in decimal and hexadecimal
- Byte value in decimal and hexadecimal
- 16-bit word in decimal and hexadecimal
- 32-bit integer in decimal and hexadecimal
- Binary bits
- 32-bit floating-point value
- 64-bit double value
- Hours, minutes, and seconds
- Unix/C `time_t` date and time
- Microsoft date and time

The macro is most useful when a file is opened in TSE binary mode. Some interpretations require two, four, or eight bytes to remain at the cursor position. When insufficient data is available, MR_HACK displays `N/A`.

## Package contents

- `MR_HACK.S` - TSE SAL source code
- `mr_hack.ini` - startup-message configuration
- `mr_hack_readme.md` - this documentation

## Requirements

- The SemWare Editor Professional or another compatible TSE version
- The TSE SAL compiler, such as `sc32.exe`
- A 32-bit TSE environment compatible with this macro

## Configuration

Keep `mr_hack.ini` in the same directory as `MR_HACK.S` and the compiled `MR_HACK.MAC` file.

```ini
[mr_hack]
silent=false
```

The `silent` parameter controls the informative message shown when the macro is run:

- `silent=false` shows the startup `Warn()` box. This is the default.
- `silent=true` suppresses the startup `Warn()` box.

The setting is not case-sensitive. If the INI file or setting is missing, MR_HACK uses `silent=false`.

## How to compile

1. Extract all files from `mr_hack1.0.0.0.0.zip` into one directory.
2. Open a command prompt in that directory.
3. Compile the source with:

```text
sc32 MR_HACK.S
```

4. Confirm that the compiler creates `MR_HACK.MAC` without errors.

Use the SAL compiler supplied for the TSE version in which the macro will run. An older `.MAC` file may not be compatible with a newer TSE SAL version, so recompiling `MR_HACK.S` is recommended.

## How to run

1. Start TSE.
2. Open the file that you want to inspect. Binary mode gives the most useful results.
3. Load or execute `MR_HACK.MAC` from TSE.
4. Unless `silent=true`, acknowledge the informative startup message.
5. Move the cursor through the file.
6. Read the automatically updated value window at the right side of the editor.

No hotkey is defined by this macro. Its display hooks remain active after the macro is loaded.

## How to stop it

Purge `MR_HACK.MAC` from TSE. Purging the macro removes its active display hooks and turns off the MR_HACK value window.

## Usage notes

- The byte order used for multi-byte values is little-endian.
- The displayed floating-point, double, time, and date values are interpretations of the same raw bytes; they are not necessarily meaningful for every cursor position.
- The `time_t` interpretation covers dates beginning in 1904 and uses 1970 as the Unix epoch.
- The Microsoft date interpretation covers approximately 1904 through 2100.
- Very large or very small floating-point values may be reported as `Too Big` or `Too Small`.
- Back up important files before testing any unfamiliar editor macro.

## Version history

### 1.0.0.0.0 - 2026-09-22

- Added this Markdown description, help, and run guide.
- Added `mr_hack.ini` with `silent=false` as the default.
- Added a configurable informative startup `Warn()` message to `Main()`.
- Preserved the original MR_HACK display and conversion behavior.
