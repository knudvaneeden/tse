# GETFISCU

**README version:** 1.0.0.0.0  
**Date:** 2026-09-06  
**Time:** 21:47:32 CEST (19:47:32 UTC)

## Description

`getfiscu.s` is a TSE SAL macro that reports the disk size, in bytes, of the file currently open in The SemWare Editor (TSE).

The macro calls `CurrFileName()` to obtain the current file's name and passes it to `FNFileGetSizeDiskI()`. On Win32, the file is located with `FindThisFile()` and its size is read with `FFSize()`.

## Package contents

- `getfiscu.s` — TSE SAL source code.

## Requirements

- The SemWare Editor (TSE) for Windows.
- The TSE SAL compiler, such as `sc32.exe`.
- A named file open in TSE. Save a new, unnamed buffer before running the macro.

## Compile

1. Extract `getfiscu.zip` to a directory of your choice.
2. Open a command prompt in that directory.
3. Compile the source:

   ```cmd
   sc32 getfiscu.s
   ```

4. Confirm that the compiler creates the compiled TSE macro.

## Run

1. Open TSE.
2. Open the file whose disk size you want to determine.
3. Load or execute the compiled `getfiscu` macro using your usual TSE macro command.
4. The size of the current file is displayed in bytes in a TSE message.

Example result:

```text
12345
```

This means that the current file occupies 12,345 bytes as reported by `FFSize()`.

## Functions

### `FNFileGetSizeDiskCurrentI()`

Returns the size of the current file by calling:

```text
FNFileGetSizeDiskI(CurrFileName())
```

### `FNFileGetSizeDiskI(filenameS)`

On Win32, searches for `filenameS` and returns its size in bytes. Hidden, system, and read-only files are included in the search.

If the file cannot be found, the macro displays a warning and returns `0`.

## Important notes

- The supplied implementation performs the size lookup only when compiled for Win32.
- The non-Win32 branch does not determine a size; Linux and macOS are therefore not supported by this version.
- A returned value of `0` can mean either that the file is empty or that it could not be found. In the latter case, a warning is displayed.
- TSE SAL `INTEGER` values are signed 32-bit values. Very large files may exceed the usable integer range.
- The reported value is the file length returned by TSE's `FFSize()`. It is not necessarily the allocated filesystem space or “size on disk” shown by Windows Explorer.

## Troubleshooting

### The macro reports that the file was not found

- Make sure the current buffer has been saved and has a valid filename.
- Confirm that the file still exists at the path shown in TSE.
- Check that the path is accessible.

### The compiler cannot find `getfiscu.s`

Change to the directory containing the extracted source, or pass the full source path to `sc32`.

### No size is returned on Linux

This package currently contains only a Win32 implementation. The non-Win32 code branch is empty.

## Version history

| Version | Date | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-06 | Initial README with description, compilation instructions, usage help, limitations, and troubleshooting. |

Future documentation revisions can increment the last component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

