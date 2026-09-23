# FILEOPENFOO

**Version:** 1.0.0.0.0  
**Date and time:** 2026-09-23 13:09 UTC (15:09 Netherlands time)

## Description

FILEOPENFOO is a small Windows program that lets you select an existing file and inspect its path. It displays the selected long path, the path returned by Windows `GetShortPathNameW`, and an ASCII representation of that returned path. The example illustrates a path conversion that may be useful when working with older programs such as 32-bit TSE. It does not open or edit the selected file.

## Package contents

| File | Purpose |
| --- | --- |
| `foo.exe` | Compiled Windows program supplied with the original package. |
| `foo.c` | C source code for Borland C++ 5.5.1. |
| `fileopenfoo.ini` | Reserved configuration file; this version does not read it. |
| `fileopenfoo_readme.md` | These instructions. |

## Run the program

1. Extract all files from `fileopenfoo1.0.0.0.0.zip` into a folder.
2. Run `foo.exe` on Windows, either by double-clicking it or by typing `foo.exe` at a command prompt in that folder.
3. Choose an existing file in the file selection dialog and click **Open**.
4. Read the message boxes showing the returned short path, original long path, and ASCII path. Click **OK** to advance through them.
5. Cancel the file selection dialog to exit without displaying paths.

## Compile from source

Use the 32-bit Borland C++ 5.5.1 command-line compiler and its Windows SDK headers and libraries. In a command prompt where `bcc32` is available, run:

```bat
bcc32 foo.c
```

The `bcc` command in some environments is a separate wrapper that copies source files into the compiler's `Bin` directory. A message saying it cannot copy `foo.c` onto itself comes from that wrapper, not from the C compiler. Compilation has succeeded when an executable is produced; the supplied `foo.exe` was built from the included source.

## Configuration

`fileopenfoo.ini` is included as requested for future options. Version 1.0.0.0.0 does not parse the INI file, so changing it has no effect. The file selector and message boxes are defined in `foo.c`.

## Notes and limitations

- The displayed result of `GetShortPathNameW` depends on Windows and the selected file system. An 8.3 alias may not be available; do not assume the displayed path always uses short 8.3 names.
- The ASCII conversion only correctly represents characters in the ASCII range. Paths containing other characters may display incorrectly in the final message box.
- Paths are stored in `MAX_PATH`-sized buffers. This demonstration is not designed for extended-length Windows paths.
- If Windows cannot obtain a path, the program shows the Windows error code.
