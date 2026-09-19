# LOWLEVEL for TSE on Microsoft Windows

**Version:** 1.0.0.0.4  
**Date and time:** 2026-09-19 23:36 CEST  
**LLM:** GPT-5.6 Sol

## Description

`LOWLEVEL` is a modernization of Peter Birch's original 1994 low-level file helper for The SemWare Editor (TSE).

The original package contained:

- `LOWLEVEL.INC`
- `LOWLEVEL.ASM`
- `LOWLEVEL.BIN`

The old `LOWLEVEL.BIN` is 16-bit DOS machine code. It calls DOS interrupt `21h` for opening, seeking, reading and closing a file. That binary mechanism is not appropriate for the 32-bit Microsoft Windows version of TSE.

Version **1.0.0.0.4** replaces that DOS binary with a **32-bit Microsoft Windows DLL** written in C++ and intended to be compiled with **Borland C++ 5.5.1**. The public SAL interface deliberately keeps the familiar routines:

```text
_open(path)
_seek(handle, offset, method)
_read(handle, buffer, bytes)
_close(handle)
```

This means old SAL code that used the four LOWLEVEL operations can usually be converted simply by including the new `lowlevel.inc` and placing `lowlevel.dll` with the macro files.

### Version 1.0.0.0.4 calling-convention correction

Runtime testing of version 1.0.0.0.1 showed that `_open()` and `_close()` worked, while the three-argument `_seek()` failed. A one-argument call does not reveal argument-order differences, but a multi-argument call does. Version 1.0.0.0.4 therefore changes the Borland DLL exports from `__pascal` to Win32 `__pascal`. The SAL declarations remain unchanged.

Both SAL source files now include the local interface with TSE's current-directory syntax:

```text
#include ["lowlevel.inc"]
```

## Why a DLL is required

The original assembly code uses DOS services directly:

- DOS function `3Dh` to open a file.
- DOS function `42h` to seek.
- DOS function `3Fh` to read.
- DOS function `3Eh` to close.

The Windows replacement uses Win32 file APIs instead:

- `CreateFileA()`
- `SetFilePointer()`
- `ReadFile()`
- `CloseHandle()`

The DLL uses the **Win32 `__pascal` calling convention**. TSE's 32-bit DLL interface can call Windows API functions directly; using `__pascal` also gives the parameter order expected by multi-argument calls such as `_seek()` and `_read()`.

## Files

### New Windows files

- `lowlevel.cpp` - Borland C++ source for the Win32 DLL.
- `lowlevel.def` - exports `LOWOPEN`, `LOWSEEK`, `LOWREAD`, and `LOWCLOSE` without relying on compiler-specific decorated names.
- `build.bat` - build script for Borland C++ 5.5.1.
- `lowlevel.inc` - TSE SAL declarations and `SEEK_SET`, `SEEK_CUR`, `SEEK_END` constants.
- `lowlevel.s` - configurable TSE test macro using `lowlevel.ini`.
- `lowlevel_demo.s` - minimal standalone demo of `_open()`, `_seek()`, `_read()`, and `_close()`.
- `lowlevel.ini` - optional defaults used by `lowlevel.s`.
- `lowlevel_readme.md` - this documentation.

### Original historical files

The package also keeps the original files for reference:

- `LOWLEVEL.ASM`
- `LOWLEVEL.BIN`
- `LOWLEVEL.INC`

Do **not** use the original `LOWLEVEL.BIN` with the Windows conversion.

## Building `lowlevel.dll`

The supplied build script assumes Borland C++ 5.5.1 is installed here:

```text
g:\language\computer\cpp\embarcadero\borland\bcc55\bin
```

Run from a Windows command prompt in the directory containing the source files:

```text
build.bat
```

The build script currently uses:

```text
BCC=G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC55\bin
TDUMP=G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC102\bin\tdump.exe
```

Because the `TDUMP` path contains no spaces, the script invokes it as `%TDUMP% -ee lowlevel.dll`. This avoids the quoted-command parsing problem seen under JPSoft TCC.

The script performs these steps:

```text
bcc32 -c -O2 -w lowlevel.cpp
ilink32 -Tpd -aa -x -c c0d32.obj lowlevel.obj, lowlevel.dll,, import32.lib cw32.lib, lowlevel.def
```

When successful, it creates:

```text
lowlevel.dll
```

It then runs `tdump.exe -ee lowlevel.dll` using `G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC102\bin\tdump.exe` so the exports can be checked. The required exported names are:

```text
LOWOPEN
LOWSEEK
LOWREAD
LOWCLOSE
```

The script contains separate `BCC=` and `TDUMP=` settings. `BCC=` points to Borland C++ 5.5.1 and `TDUMP=` points to the installed BCC102 copy of `tdump.exe`. Edit either setting only if its executable is moved. The batch file now ends naturally instead of executing `EXIT /B`, avoiding the extra TCC `exit:` help line after a successful build.

## Compiling the TSE macro

Keep these files together in the same macro directory:

```text
lowlevel.s
lowlevel_demo.s
lowlevel.inc
lowlevel.ini
lowlevel.dll
```

Compile the test macro with the Windows SAL compiler:

```text
sc32 lowlevel.s
```

This should create:

```text
lowlevel.mac
```

The DLL declaration in `lowlevel.inc` is:

```text
dll "lowlevel.dll"
```

Therefore the DLL must be available to the Windows TSE process. Keeping `lowlevel.dll` with the macro is the intended portable arrangement.


## Minimal demo: `lowlevel_demo.s`

`lowlevel_demo.s` is the simplest runtime test of the Windows DLL. It does not require any INI settings. It operates on the file that is currently open in TSE.

The demo performs these operations in order:

1. `CurrFilename()` obtains the current file name.
2. `_open()` opens that file through `lowlevel.dll`.
3. `_seek()` moves to byte position 0 using `SEEK_SET`.
4. `_read()` reads up to 80 bytes into a normal TSE string.
5. `_close()` closes the LOWLEVEL handle.
6. One final `Warn()` displays the position, byte count, close result, and data read.

Compile it with:

```text
sc32 lowlevel_demo.s
```

Then open a normal file in TSE and execute:

```text
lowlevel_demo.mac
```

A successful result should show values similar to:

```text
LOWLEVEL 1.0.0.0.4  position=0  bytes=80  data=[...]  close=0
```

A `close=0` result means `_close()` succeeded.

## `lowlevel.ini`

The INI file is used by the supplied `lowlevel.s` test/demo macro.

Default contents:

```ini
[lowlevel]
testfile=
seekoffset=0
seekmethod=0
readbytes=32
```

### `testfile`

Full path of the file to test.

When it is empty, `lowlevel.s` uses the file currently being edited in TSE.

Example:

```ini
testfile=c:\temp\example.zip
```

### `seekoffset`

Signed byte offset passed to `_seek()`.

Default:

```ini
seekoffset=0
```

### `seekmethod`

The seek origin:

```text
0 = SEEK_SET = beginning of file
1 = SEEK_CUR = current file position
2 = SEEK_END = end of file
```

Default:

```ini
seekmethod=0
```

### `readbytes`

Number of bytes to read into a TSE string.

Default:

```ini
readbytes=32
```

TSE strings have a maximum length of 255 bytes, so the demo limits this setting to 255.

## How to run the test

1. Build `lowlevel.dll` with `build.bat`.
2. Put `lowlevel.dll`, `lowlevel.inc`, `lowlevel.ini`, and `lowlevel.s` in the same TSE macro directory.
3. Optionally edit `lowlevel.ini` and set `testfile=` to a file that should be read.
4. If `testfile=` is empty, open a normal file in TSE before running the test.
5. Compile:

   ```text
   sc32 lowlevel.s
   ```

6. Execute `lowlevel.mac` from TSE.
7. The final `Warn()` reports the file, resulting file position, number of bytes read, close status, and the data read.

## Using LOWLEVEL from another SAL macro

Include the interface:

```text
#include ["lowlevel.inc"]
```

Then use the same logical sequence as the historical implementation:

```text
handle = _open(filename)
position = _seek(handle, offset, SEEK_SET)
bytesRead = _read(handle, buffer, bytesWanted)
_close(handle)
```

### Return values

`_open()`:

- Positive integer: LOWLEVEL handle.
- `-1`: error.

`_seek()`:

- Non-negative integer: new byte position.
- `-1`: error.

`_read()`:

- `0` or greater: number of bytes actually read.
- `-1`: error.

`_close()`:

- `0`: success.
- `-1`: error.

## Compatibility notes

### TSE string layout

TSE passes a `VAR STRING` to a DLL as a pointer to its internal length-prefixed string together with the string's maximum length. `LOWREAD` understands that layout and updates the TSE string length after `ReadFile()` succeeds.

### Maximum read size

The original 1994 assembly explicitly stated that the number of bytes read had to be less than 256. This remains a sensible restriction because a TSE SAL string has a maximum capacity of 255 bytes.

### File offsets

SAL integers are signed 32-bit values. To remain compatible with the original `_seek()` interface, this version returns `-1` when the resulting position cannot be represented as a positive SAL integer. This helper is therefore intended for low-level inspection of ordinary file regions, not as a general 64-bit large-file API.

### Handle implementation

The DLL does not expose raw Win32 `HANDLE` values to SAL. Instead it maintains a small internal handle table and returns IDs from 1 through 64. This avoids pointer/handle representation problems and keeps the SAL-facing interface integer-only.

### Sharing mode

The old DOS routine opened files read-only with sharing allowed. The Windows implementation therefore opens with `GENERIC_READ` and permits read, write, and delete sharing where Windows allows it.

## Portability

This conversion targets:

- Microsoft Windows 10/11.
- 32-bit TSE for Windows.
- TSE SAL 4.50.x.
- A 32-bit `lowlevel.dll`.
- Borland C++ 5.5.1 as the supplied build environment.

It is not intended for the Linux build of TSE because the Win32 DLL interface is Windows-specific.

## Historical behavior retained

The new implementation intentionally preserves the purpose of the original package: reading a small part of a potentially very large file without loading that entire file into an editor buffer.

A typical use is examining a file header, archive signature, executable header, or a few bytes near a known offset.


## Version 1.0.0.0.4 ABI correction

Runtime testing showed that `LOWOPEN` and `LOWCLOSE` worked, while the three-argument `LOWSEEK` returned `-1`. This indicated that the handle itself was valid but the arguments of multi-parameter DLL calls were reaching the Borland Win32 entry point in the opposite order.

Version 1.0.0.0.4 therefore keeps the SAL declarations unchanged but reverses the C parameter declarations for the multi-argument exports:

- SAL `_seek(handle, offset, method)` maps to C `LOWSEEK(method, offset, handle)`.
- SAL `_read(handle, buffer, bytes)` maps to C `LOWREAD(bytes, maxLen, buffer, handle)`, including the hidden TSE string maximum-length argument.

This preserves the original SAL-facing API while compensating inside the DLL for the stack order used by the TSE DLL interface. The final test warning also shows the numeric handle to make runtime verification easier.

## Version history

### 1.0.0.0.0 - 2026-09-19 22:34 CEST

- Converted the original DOS interrupt `21h` implementation to a 32-bit Microsoft Windows DLL design.
- Added `lowlevel.cpp` for Borland C++ 5.5.1.
- Initially used `__pascal` exports; runtime testing later showed that multi-argument DLL calls require the Win32 `__pascal` convention used in version 1.0.0.0.4.
- Added `lowlevel.def` with stable export names.
- Added `build.bat`.
- Configured `TDUMP=G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC102\bin\tdump.exe`.
- The TCC-safe `tdump` invocation uses `%TDUMP% -ee lowlevel.dll` without surrounding command-name quotes because this path contains no spaces.
- Replaced the binary declaration in the historical include file with a Windows DLL declaration in `lowlevel.inc`.
- Preserved `_open`, `_seek`, `_read`, `_close`, `SEEK_SET`, `SEEK_CUR`, and `SEEK_END` at the SAL level.
- Added `lowlevel.ini`.
- Added `lowlevel.s` as a test/demo macro using the INI values.
- Added this Markdown documentation.


### 1.0.0.0.1 - 2026-09-19 22:50 CEST

- Renamed the build script to `build.bat`.
- Updated `TDUMP` to `G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC102\bin\tdump.exe`.
- Added `lowlevel_demo.s`.
- Verified that the DLL builds and exports `LOWOPEN`, `LOWSEEK`, `LOWREAD`, and `LOWCLOSE`.

### 1.0.0.0.4 - 2026-09-19 23:36 CEST

- Changed all DLL exports from Borland `__pascal` to Win32 `__pascal` after runtime testing showed `_seek()` receiving multi-argument calls incorrectly.
- Changed local SAL includes to `#include ["lowlevel.inc"]`.
- Removed `EXIT /B` from the successful end of `build.bat` to avoid the extra JPSoft TCC `exit:` help line.
- Updated `lowlevel.s`, `lowlevel_demo.s`, `lowlevel.cpp`, `lowlevel.def`, `lowlevel.inc`, and this README to version 1.0.0.0.4.
- No precompiled `lowlevel.dll` is shipped in this iteration because the previous DLL was built from the 1.0.0.0.1 `__pascal` source. Run `build.bat` to create the corrected DLL.

## Important build note

This package contains the complete C++ DLL source and Borland build script. The DLL binary itself must be produced by running `build.bat` on Windows with Borland C++ 5.5.1 available. The current packaging environment does not contain the Borland compiler, so it cannot truthfully include a Borland-built `lowlevel.dll` binary yet.


## Version 1.0.0.0.4 correction

The Windows DLL is compiled with Borland `__pascal`, and every corresponding SAL DLL declaration now explicitly includes the `PASCAL` modifier. This is required by TSE for Pascal-calling-convention DLL functions. Earlier versions omitted `PASCAL` in `lowlevel.inc`, so one-argument calls could appear to work while multi-argument calls such as `_seek()` received arguments incorrectly.

The interface is now:

```text
dll "lowlevel.dll"
    integer proc PASCAL _open(string path : cstrval) : "LOWOPEN"
    integer proc PASCAL _seek(integer handle, integer offset, integer method) : "LOWSEEK"
    integer proc PASCAL _read(integer handle, var string buffer, integer bytes) : "LOWREAD"
    integer proc PASCAL _close(integer handle) : "LOWCLOSE"
end
```
