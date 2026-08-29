# TSE ASCII Chart DLL edition

Version 1.0.0.0.4

This package ports the single assembler routine in DiK's 1995 public-domain
ASCII Chart macro to a 32-bit Windows DLL. The original BIOS interrupts are
replaced by the Win32 console functions `GetConsoleScreenBufferInfo()` and
`ReadConsoleOutputCharacterA()`.

## Build with Borland C++ 5.5

1. Open a Windows command prompt in this directory.
2. Ensure the Borland `BCC55\\Bin` directory is on `PATH` and its include and
   library directories are configured in `bcc32.cfg` and `ilink32.cfg`.
3. Run `build.bat`.
4. Confirm that it reports `Built asciidll.dll successfully` without the
   earlier `Attempt to export non-public symbol` warning.

The result is `asciidll.dll`, a 32-bit DLL suitable for 32-bit TSE.

## Install and run

1. Put `ascii.s` and the compiled `asciidll.dll` in the same directory.
2. Compile `ascii.s` with TSE's Macro Compile command.
3. Keep `asciidll.dll` beside the resulting `ascii.mac`, or in a directory
   where Windows/TSE can find it.
4. Execute `ascii.mac`.

The keyboard and mouse controls match the original macro. `F1` displays its
help screen.

## Important compatibility note

The DLL reads a Windows console screen buffer and therefore supports the
console edition of TSE (`e32.exe`). The GUI edition (`g32.exe`) does not expose
its character cells through the Windows console API. The chart itself and
insertion work in either edition, but the special operation that clicks outside
the chart to identify a displayed character returns a space in `g32.exe`.

The package contains source code because this environment cannot run Borland
C++ 5.5 to compile or test the Windows DLL. Version 1.0.0.0.1 corrected the
Borland export definition and removed the `tdump | find` check, which can be
misinterpreted by JPSoft TCC aliases. Version 1.0.0.0.2 replaces the reserved
SAL parameter names `min` and `max` with `minI` and `maxI`. Version
1.0.0.0.3 uses the SAL statement `Halt` instead of the invalid `Halt()` call.
Version 1.0.0.0.4 renames this documentation file to `ascii_readme.md`.
