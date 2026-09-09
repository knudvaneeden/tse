# FINFO_32 compatible version

**Version:** 1.0.0.0.1  
**Date:** 2026-09-09  
**Target:** TSE SAL Compiler V4.50.rc23, 32-bit TSE for Microsoft Windows  
**LLM:** OpenAI GPT-5 Codex

## Description

This package ports the 1994 FINFO_32 source to current 32-bit TSE for Microsoft Windows. It replaces the obsolete DOS `FILEINFO.BIN` binary procedure and DOS find-data structure with a small Win32 DLL.

The original three macro entry points remain available:

- `fileinfo.s` displays the current file's path, size, modification date, modification time, and Windows attributes. It can change Read-only, Archive, System, and Hidden.
- `is_read.s` sets the global integer `giCurrFileIsReadOnly` to `TRUE` or `FALSE`.
- `tog_read.s` toggles the current file's Read-only attribute.

## Important compatibility rule

Never use the old `.mac` files with a current TSE SAL version. Compile the supplied `.s` files with the SAL compiler belonging to the installed TSE version. This creates new, version-compatible `.mac` files.

## Files

| File | Purpose |
| --- | --- |
| `fileinfo.s` | File-information and attribute-changing macro. |
| `is_read.s` | Read-only test macro. |
| `tog_read.s` | Read-only toggle macro. |
| `finfo32.inc` | Shared SAL DLL declarations and helper procedures. |
| `finfo32.c` | Win32 DLL source. |
| `finfo32.def` | DLL export definition. |
| `build.bat` | Borland C++ 5.5.1 build script. |

## Build the DLL

1. Put all package files in one directory.
2. Open a Windows command prompt configured for Borland C++ 5.5.1.
3. Run:

   ```bat
   build.bat
   ```

4. Confirm that the final message is `Built finfo32.dll successfully.`

## Compile the SAL macros

Keep `finfo32.inc` in the same directory as the `.s` files, then run:

```bat
sc32 fileinfo.s
sc32 is_read.s
sc32 tog_read.s
```

Use only the newly generated `fileinfo.mac`, `is_read.mac`, and `tog_read.mac` with the current TSE installation.

## Installation

Copy these files to a directory from which TSE can load them:

- `fileinfo.mac`
- `is_read.mac`
- `tog_read.mac`
- `finfo32.dll`

The DLL must be discoverable by Windows when TSE loads a macro. Keeping the DLL with the macros may work when that directory is already in the DLL search path; otherwise place it beside the TSE executable or in another explicitly configured application DLL directory.

## Running the macros

With an existing file open in TSE, run one of:

```sal
ExecMacro("fileinfo")
ExecMacro("is_read")
ExecMacro("tog_read")
```

After `is_read`, retrieve the result with:

```sal
IF (GetGlobalInt("giCurrFileIsReadOnly"))
    Message("The current file is read-only")
ELSE
    Message("The current file is not read-only")
ENDIF
```

## Notes

- The port uses ANSI Windows API calls because TSE SAL is ASCII-only.
- Paths are limited to the TSE string limit of 255 characters.
- Exact file sizes through 2,147,483,647 bytes are displayed. Larger sizes are reported as greater than that limit because a SAL `INTEGER` is signed 32-bit.
- The displayed timestamp is the file's last-write time converted to local DOS date/time resolution.
- The original compiled `.mac` files and `FILEINFO.BIN` are intentionally not included.

## Version history

### 1.0.0.0.1 — 2026-09-09

- Replaced the unavailable `INVALID_FILE_ATTRIBUTES` symbol with its Win32 value `0xFFFFFFFFUL` for Borland C++ 5.5 compatibility.

### 1.0.0.0.0 — 2026-09-09

- Replaced the 16-bit DOS binary procedure with a 32-bit Windows DLL.
- Added sources for Borland C++ 5.5.1.
- Retained the original three macro roles.
- Added explicit current-version recompilation instructions.
