# INTENSE2 Win32 DLL port

Version 1.0.0.0.5 - 11 September 2026, 19:05 CEST

This package replaces the 16-bit DOS `COLORS.BIN` declaration with a 32-bit
Win32 DLL that can be built using Borland C++ 5.5.1.

## Build

1. Open a Borland C++ 5.5.1 command prompt.
2. Put `colorsdll.c`, `colors.def`, and `build.bat` in the same directory.
3. Run `build.bat`.
4. Confirm that `colors.dll` was created.

## Compile and run the SAL demo

1. Copy `colors.dll`, `colors.s`, and `intense2_demo.s` to the same directory.
2. Run `sc32 intense2_demo.s`.
3. Copy `intense2_demo.mac` and `colors.dll` to a directory in TSE's macro
   search path. Keeping both beside each other is recommended.
4. Run `intense2_demo` in TSE Pro.

The final warning reports the requested bright and overscan values. While the
warning is open, the INTENSE2-style colors remain visible. Press OK to restore
the colors that were active before the demo ran.

The DLL build was confirmed successful with Borland C++ 5.5.1 on 11 September
2026. Version 1.0.0.0.1 renames the demo constant from the reserved SAL keyword
`VERSION` to `MACRO_VERSION`, allowing compilation with SAL Compiler 4.50.rc23.

Version 1.0.0.0.2 adds Borland's `#pragma argsused` to `DllEntryPoint`, removing
the three harmless W8004 unused-parameter warnings without changing DLL
behavior.

Version 1.0.0.0.3 replaces the string-valued `#DEFINE MACRO_VERSION` with the
local SAL string `macroVersionS`. SAL Compiler 4.50 expects a numeric expression
in a `#DEFINE`, so this corrects Error 2336 at line 3 of `intense2_demo.s`.

Version 1.0.0.0.4 adds a visible TSE-native color effect. The demo saves the
current editing colors, applies the original INTENSE2 palette idea and a red
status-line accent, and restores all saved colors after the warning closes.

Version 1.0.0.0.5 replaces configuration-only color symbols such as
`CursorAttr` with the external-macro-safe `SetColorTableValue()` API. It
temporarily makes black backgrounds red, white backgrounds blue, and green
foregrounds bright green. The exact previous RGB values are restored after OK.

## Compatibility limitation

The original code invoked VGA BIOS interrupt `10h`. Win32 has no equivalent
VGA overscan-border API, and modern Windows already interprets the background
intensity bit as intensity rather than blinking. Therefore `Bright()` and
`Overscan()` safely retain and report the requested values but do not alter
the Windows desktop, TSE GUI, or console palette. This avoids changing
unrelated console colours while preserving source compatibility.

No `LoadDir()` call or fixed installation path is used.
