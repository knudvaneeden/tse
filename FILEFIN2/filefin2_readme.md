# FILEFIN2 Win32 DLL port

**Version:** 1.0.0.0.13  
**Date:** 2026-09-08  
**Time:** 02:30 CEST (UTC+02:00)  
**LLM:** OpenAI Codex  

## Description

This package ports the 1994 FILEFIN2 macro to 32-bit TSE Pro 4.50 on Windows 11. The unsupported SAL `binary` declarations have been removed. Their DOS `.BIN` modules are replaced by two Win32 DLLs whose source can be compiled with Borland C++ command-line compiler 5.5.1.

- `ff.dll` replaces `FF.BIN` and uses the Win32 file-search API.
- `zip.dll` replaces the old `LOWLEVEL.BIN`-based ZIP reader and reads the ZIP central directory.
- Modern ZIP support includes data-descriptor archives, UTF-8 member names, and ZIP64 sizes and offsets.
- ZIP member masks are evaluated once per central-directory entry in `zip.dll`; the former SAL repeat-search loop and its duplicate output are removed.
- Directory traversal is recursive below the supplied starting directory and includes normal, read-only, hidden, and system directories while avoiding reparse-point loops.
- Complete depth-first directory traversal now runs inside `ff.dll`. Win32 search handles remain on an internal stack until every sibling branch has been visited; traversal no longer depends on recursive SAL locals or temporary-buffer queue positioning.
- The DLL sources use Win32 functions only and do not require unresolved Borland C runtime functions such as `strlen`, `memcpy`, `atol`, or `sprintf`.
- The reserved SAL names `FindFirst` and `FindNext` are replaced by `FNFindFirstI` and `FNFindNextI`.
- Separate DLL search contexts preserve recursive searches.
- The search prompt uses TSE's `_EDIT_HISTORY_`, so earlier path/mask entries can be recalled.
- `FF.S` is standalone: its DLL declarations and ZIP helper are embedded directly, so compiling it does not open or retain `FF.INC` or `ZIP.INC` editor buffers.
- Double quotes are ignored while parsing search input. Both `C:\TEMP\FF.S` and `"C:\TEMP\FF.S"` therefore search the same valid Windows path; an unmatched quote recalled from input history is also harmless.
- Pressing **Ctrl+Alt+Shift+F** runs the FILEFIN2 search prompt directly while the compiled macro is loaded.
- Filename masks accept `*` or `.*` anywhere for zero or more characters and `?` anywhere for exactly one character. This applies identically to ordinary filenames and member names inside ZIP files.
- ZIP masks are matched against the final member filename, not the ZIP's internal directory prefix. Thus `FF.S` finds `filefin2_portable_1.0.0.0.13/FF.S`, while the full internal member path remains visible in the results.

## Files

| File | Purpose |
|---|---|
| `FF.S` | Updated main TSE SAL macro |
| `ff_dll.c` | Borland C source for `ff.dll` |
| `zip_dll.c` | Borland C source for the modern central-directory `zip.dll` |
| `build.bat` | Builds both 32-bit DLLs |

## Build the DLLs

1. Open a Windows command prompt.
2. Make the Borland C++ 5.5.1 `Bin` directory available through `PATH`, or run `build.bat` from a command prompt in which `bcc32.exe` is already available.
3. Change to the extracted FILEFIN2 directory.
4. Run:

   ```bat
   build.bat
   ```

5. A successful build ends with:

   ```text
   Build completed: ff.dll and zip.dll
   ```

The batch file uses:

```bat
bcc32 -tWD -O2 -u- -eff.dll ff_dll.c
bcc32 -tWD -O2 -u- -ezip.dll zip_dll.c
```

`-tWD` creates a Win32 DLL. `-u-` disables Borland's leading underscore on exported C names so TSE can resolve the exact names declared in the SAL `dll` blocks. The exported functions use the Pascal/WinAPI calling convention required by 32-bit TSE DLL calls.

## Compile the SAL macro

After both DLLs build successfully, compile the updated macro with the TSE SAL Compiler:

```bat
sc32 FF.S
```

No `.INC` files are required. Version 1.0.0.0.9 embeds the declarations directly in `FF.S`.

## Install and run

1. Put the compiled `FF.MAC` where TSE loads macros.
2. Put `ff.dll` and `zip.dll` in a directory from which Windows can load them. The simplest choices are the directory containing the TSE executable or another directory already in `PATH`.
3. Restart TSE after replacing either DLL, because Windows/TSE may retain a loaded DLL in memory.
4. Execute the `FF` macro, or press **Ctrl+Alt+Shift+F** while it is loaded. The macro creates and displays a dedicated results buffer.
5. Enter either a wildcard mask or a full starting path and mask, such as `*.S`, `e.*list`, `elist.?`, `FILE?.TXT`, or `C:\TEMP\*.TXT`.
6. When only a wildcard is entered, searching starts at the root of the current drive. When a path is included, searching starts in that directory.
7. Choose whether member names inside ZIP files should also be searched.

The macro recursively appends matching filenames, sizes, dates, and times to its dedicated results buffer. Searching starts at the supplied directory, or at the root of the current drive when only a mask is entered.

## Wildcard examples

| Mask | Matches |
|---|---|
| `e.*list.s` | Names beginning with `e`, followed by any characters, and ending in `list.s`; for example `eList.s` |
| `elist.?` | `elist.` followed by exactly one character, such as `elist.s` |
| `*elist*` | Any name containing `elist` |
| `file?.txt` | Names such as `file1.txt` or `fileA.txt`, but not `file10.txt` |

## Troubleshooting

### TSE reports that a DLL or procedure cannot be found

- Confirm that both DLLs are reachable from the TSE process.
- Restart TSE after rebuilding the DLLs.
- Run `tdump -ee ff.dll` and `tdump -ee zip.dll` to inspect the export tables.
- Confirm that the exported names match the `dll` declarations near the top of `FF.S` exactly.
- Confirm that `-u-` is present in both `bcc32` commands.

### The SAL compiler still reports `Binary not supported`

Compile the updated standalone `FF.S`. It contains no `binary` declarations and needs no FILEFIN2 include files.

### The SAL compiler reports that `FindFirst` is reserved

You are compiling an older source. Version 1.0.0.0.9 is standalone and contains no `FindFirst` or `FindNext` SAL procedures.

### ZIP searching fails

The DLL searches the central directory, so compression method and data descriptors do not affect member-name listing. Classic ZIP and ZIP64 metadata are supported. Multi-disk/spanned archives are not supported. UTF-8 member names are converted to the active Windows ANSI code page because TSE 4.50 SAL strings are not Unicode.

### Large file sizes show `2147483647`

TSE SAL integers are signed 32-bit values. Sizes above 2,147,483,647 bytes are clamped to that maximum value.

## Version history

| Version | Date | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-07 | Documentation of the original DOS `.BIN` package |
| 1.0.0.0.1 | 2026-09-07 | Replaced both `.BIN` interfaces with Borland C++ 5.5-compatible Win32 DLL sources and updated SAL code |
| 1.0.0.0.2 | 2026-09-07 | Removed Borland C runtime dependencies, added TSE 4.50/Windows 11 compatibility updates, and replaced the ZIP reader with central-directory, UTF-8, data-descriptor, and ZIP64 support |
| 1.0.0.0.3 | 2026-09-07 | Removed Borland C++ W8012 signed/unsigned comparison warnings in the ZIP64 extra-field parser |
| 1.0.0.0.4 | 2026-09-07 | Corrected full-path input parsing, added a dedicated visible results buffer and an explicit no-results message, and removed the obsolete conversion include |
| 1.0.0.0.5 | 2026-09-08 | Fixed repeated ZIP-member duplicates and made recursion cover all ordinary subdirectories while excluding reparse-point loops |
| 1.0.0.0.6 | 2026-09-08 | Replaced recursive SAL directory enumeration with an explicit queue so child searches cannot overwrite the parent search state |
| 1.0.0.0.7 | 2026-09-08 | Moved complete recursive traversal into `ff.dll` after the SAL queue still skipped sibling branches |
| 1.0.0.0.8 | 2026-09-08 | Added `_EDIT_HISTORY_` to the search prompt and made `FF.S` standalone so compiling it no longer loads or retains include-file buffers |
| 1.0.0.0.9 | 2026-09-08 | Fixed quoted and accidentally half-quoted search input by removing double quotes before splitting the starting directory and file mask |
| 1.0.0.0.10 | 2026-09-08 | Added the **Ctrl+Alt+Shift+F** key assignment for starting a search |
| 1.0.0.0.11 | 2026-09-08 | Documented and exposed `*` and `?` wildcard searching in the prompt, including `e.*list` and `elist.?` examples |
| 1.0.0.0.12 | 2026-09-08 | Made `.*` a wildcard alias for `*`, so a mask such as `e.*list.s` matches `eList.s` |
| 1.0.0.0.13 | 2026-09-08 | Fixed ZIP searches by matching the mask against each member's basename instead of its complete internal directory path |
