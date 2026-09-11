# INTENSE2

## Document information

- **Session:** Create INTENSE2 MarkDown Readme
- **README version:** 1.0.0.0.6
- **Date:** 11 September 2026
- **Time:** 19:05 CEST (17:05 UTC)
- **Original package date:** 23 July 1993

## Description

INTENSE2 is a historical DOS and TSE (The SemWare Editor) example package that demonstrates how a TSE SAL macro can call 16-bit machine code to control VGA color behavior.

The package provides two routines:

- `bright(TRUE)` enables high-intensity background colors instead of blinking text.
- `bright(FALSE)` restores blinking text behavior.
- `overscan(Attr)` sets the VGA overscan, or screen-border, color.

The included `COLORS.S` file declares these routines and loads them from `COLORS.BIN`. The sample in `README.NOW` shows how to call them from a macro's `WhenLoaded()` procedure. `COLORS.ASM` contains the original assembly source, while `COLORS.OBJ` and `SHOWCOLO.EXE` are supporting historical DOS files.

## Package contents

| File | Purpose |
|---|---|
| `README.NOW` | Original notes and example SAL code |
| `COLORS.S` | SAL declarations for `overscan()` and `bright()` |
| `COLORS.BIN` | 16-bit DOS machine-code routines loaded by TSE |
| `COLORS.ASM` | Assembly source for the routines |
| `COLORS.OBJ` | Compiled 8086 object file |
| `SHOWCOLO.EXE` | DOS demonstration program |

## Requirements

- A DOS-compatible version of TSE that supports SAL `binary` declarations.
- VGA-compatible display hardware or a DOS environment/emulator that implements the required BIOS video services.
- A TSE installation in which `COLORS.BIN` is available at the path declared in `COLORS.S`.

> **Important:** The supplied binary code is 16-bit DOS code. It is not a Win32 DLL and is not expected to work directly with modern Windows versions of TSE, including TSE Pro 4.50 on 64-bit Windows 11.

## Win32 DLL replacement

The updated `intense2_dll_portable.zip` package replaces the obsolete SAL
`binary` declaration with a 32-bit `colors.dll`. It includes Borland C++ 5.5.1
source, a command-line build script, new `colors.s` declarations, and a runnable
`intense2_demo.s` test macro.

The replacement uses the Pascal calling convention required by TSE SAL and
contains no `LoadDir()` call or hard-coded TSE installation directory.

### Build the DLL

1. Extract `intense2_dll_portable.zip`.
2. Open the Borland C++ 5.5.1 command-line environment.
3. Change to the extracted directory.
4. Run `build.bat`.
5. Confirm that `colors.dll` is created.

### Compile and run the DLL demo

1. Keep `colors.dll`, `colors.s`, and `intense2_demo.s` together.
2. Compile the demo with `sc32 intense2_demo.s`.
3. Put `intense2_demo.mac` and `colors.dll` in the same TSE macro-search directory.
4. Run `intense2_demo` in TSE Pro.
5. The final `Warn()` displays the stored bright and overscan values.

Windows does not provide equivalents for the two VGA BIOS operations. The DLL
therefore preserves the API and stores the requested values safely, but it does
not change the TSE GUI, Windows desktop, or console border.

Demo version 1.0.0.0.4 adds a visible TSE-native equivalent using the runtime
color-table API supported by external macros. It temporarily maps black
backgrounds to red, white backgrounds to blue, and green foregrounds to bright
green. Pressing OK restores the exact previous RGB values.

## Installation

1. Extract `intense2.zip` to a working directory.
2. Copy `COLORS.S` to the directory containing the SAL source that will use it, or place it in a directory searched by the SAL compiler.
3. Copy `COLORS.BIN` to `\TSE\BIN\COLORS.BIN` on the current drive.
4. Check the following declaration in `COLORS.S` and change it if your TSE directory is different:

   ```sal
   binary "\tse\bin\colors.bin"
       proc overscan(Integer Attr)  : 0
       proc bright(Integer OnOrOff) : 3
   end
   ```

5. Add this line to the SAL macro that will use the routines:

   ```sal
   #include "colors.s"
   ```

## How to run it

1. Add calls such as the following to your macro's `WhenLoaded()` procedure or another suitable procedure:

   ```sal
   proc WhenLoaded()
       overscan(4)
       bright(TRUE)
   end
   ```

2. Compile the main SAL source file with the SAL compiler supplied with your compatible DOS version of TSE.
3. Load or execute the resulting macro in TSE.
4. Confirm that the screen border changes color and that background colors are displayed as high-intensity colors rather than as blinking text.

The supplied example uses `overscan(4)`, described by the original documentation as selecting a red overscan color.

## Using the routines

### Enable intense background colors

```sal
bright(TRUE)
```

This disables the VGA blink attribute and permits the high bit of a background color to select an intense background.

### Restore blinking text

```sal
bright(FALSE)
```

This restores the traditional VGA blinking-text interpretation.

### Set the VGA border color

```sal
overscan(4)
```

Pass the desired VGA color attribute to `overscan()`.

## Example color settings

The original notes include settings similar to these:

```sal
CursorAttr     = Color(Green on Black)
HiLiteAttr     = Color(Bright Blue on Black)
TextAttr       = 130
EofMarkerAttr  = 131
MsgAttr        = Color(Bright White on Black)
StatusLineAttr = Color(Black on Red)
```

Numeric attributes such as `130` and `131` rely on intense-background mode being enabled.

## Troubleshooting

### `COLORS.BIN` cannot be found

The declaration in `COLORS.S` uses the fixed path `\tse\bin\colors.bin`. Copy the file there or edit the declaration so that it points to the actual file location before compiling the main macro.

### No visible border-color change

Some displays, video adapters, terminal windows, virtual machines, and DOS emulators do not show a VGA overscan border. The BIOS call may complete even when no visible border exists.

### Colors blink instead of becoming brighter

Verify that `bright(TRUE)` is executed after the macro loads. The video environment must also emulate VGA BIOS interrupt `10h`, function `1003h`.

### The macro fails under modern TSE or Windows

This package uses a 16-bit DOS `.BIN` routine and BIOS interrupts. A modern Windows-compatible implementation would require replacement code designed for Win32 TSE and the Windows console or display API; the original binary cannot simply be renamed as a DLL.

## Restoring the original display mode

Before unloading the macro or leaving the editor, call:

```sal
bright(FALSE)
```

The archive does not include automatic cleanup code, so a macro using INTENSE2 should restore the preferred display mode itself when appropriate.

## Version history

| Version | Date and time | Changes |
|---|---|---|
| 1.0.0.0.6 | 11 September 2026, 19:05 CEST | Replaced configuration-only color variables with the external-macro-safe `SetColorTableValue()` API |
| 1.0.0.0.5 | 11 September 2026, 19:00 CEST | Added a visible TSE-native INTENSE2 color demonstration with automatic restoration after the warning closes |
| 1.0.0.0.4 | 11 September 2026, 18:50 CEST | Replaced the string-valued `#DEFINE` with local string `macroVersionS`, correcting SAL Error 2336 |
| 1.0.0.0.3 | 11 September 2026, 18:49 CEST | Added Borland `#pragma argsused` to eliminate the three W8004 warnings from `DllEntryPoint` |
| 1.0.0.0.2 | 11 September 2026, 18:45 CEST | Confirmed the Borland C++ 5.5.1 DLL build and renamed the reserved SAL constant `VERSION` to `MACRO_VERSION` in the demo |
| 1.0.0.0.1 | 11 September 2026, 17:35 CEST | Added instructions for the portable Win32 DLL replacement and its test macro |
| 1.0.0.0.0 | 11 September 2026, 17:30 CEST | Initial Markdown README with description, package contents, installation, usage, compatibility notes, examples, and troubleshooting |

## Credits

The assembly source identifies **Peter Birch** as the author of the `overscan` and `bright` routines, dated 23 July 1993.
