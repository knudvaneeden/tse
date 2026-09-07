# getfisme — Current Buffer Memory Size for TSE

- **README version:** 1.0.0.0.0
- **Date and time:** 2026-09-07 11:34:02 UTC
- **Package:** `getfisme.zip`
- **Source macro:** `getfisme.s`
- **Compiled macro:** `getfisme.mac`
- **Language:** TSE SAL (SemWare Editor macro language)

## Description

`getfisme` is a TSE SAL macro that calculates the approximate number of bytes used by the complete current editor buffer. It marks the entire buffer, totals the length of every line, adds two bytes per line for the CR/LF line ending, and displays the result in a warning dialog.

The macro does not change the text or the user's existing block selection. It saves and restores both the cursor position and block state.

## Included files

| File | Purpose |
| --- | --- |
| `getfisme.s` | SAL source code that can be inspected, modified, and compiled. |
| `getfisme.mac` | Precompiled TSE macro, ready to load and run. |

## Requirements

- The SemWare Editor (TSE) for Windows.
- The SAL compiler `sc32` is required only when rebuilding `getfisme.s`.

## How to install

1. Extract `getfisme.zip` to a folder of your choice.
2. Copy `getfisme.mac` to your normal TSE macro directory, or leave it in the extracted folder and load it by its full path.
3. If you prefer to compile the source yourself, open a command prompt in the extracted folder and run:

   ```cmd
   sc32 getfisme.s
   ```

4. Confirm that compilation creates or updates `getfisme.mac` without errors.

## How to run

1. Start TSE and open the file whose current buffer size you want to inspect.
2. Load or execute `getfisme.mac` using your usual TSE macro-loading method.
3. Press **F12**.
4. TSE displays a message similar to:

   ```text
   Total bytes used in this buffer = 12345
   ```

The value is returned in bytes.

## Help and technical behavior

The source provides two reusable procedures:

- `FNFileGetBufferMemorySizeCurrentI()` marks the complete current buffer and returns its calculated size.
- `FNBlockGetBufferMemorySizeCurrentI()` returns the calculated size of the currently marked block. If no block is marked, it displays `Please mark a block` and returns `-1`.

The calculation adds `CurrLineLen() + 2` for every included line. The extra two bytes represent the CR/LF characters normally used at the end of a Windows text line.

## Important notes

- This reports an estimated **in-memory text-buffer size**, not necessarily the exact on-disk file size.
- The value can differ from the disk size when a file uses another line-ending format, a multibyte encoding, or editor/file metadata.
- The calculation uses a TSE SAL `INTEGER`; exceptionally large buffers are therefore subject to the integer limits of the installed TSE version.
- The default hotkey is `<F12>`. Change the line `<F12> Main()` in `getfisme.s` if that key conflicts with another macro, and then recompile.

## Troubleshooting

### Pressing F12 does nothing

- Make sure `getfisme.mac` has been loaded.
- Check whether another macro or TSE configuration already uses F12.
- Run the macro directly through TSE's macro execution command if necessary.

### Compilation fails

- Verify that `sc32.exe` is installed and available through the command prompt's `PATH`, or invoke it with its full path.
- Compile the supplied `getfisme.s` with a compatible TSE SAL compiler.
- Ensure the source file was extracted completely and was not altered by an incompatible text encoding conversion.

### The displayed value differs from the file size in Windows Explorer

This is expected in some cases. The macro calculates the buffer's text size using two line-ending bytes for every line. It does not query the operating system for the physical file size.

## Version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-07 11:34:02 | Initial README with description, installation, usage, help, technical notes, and troubleshooting. |

## Version-number convention

Future README revisions increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
...
```

The version metadata embedded in the supplied SAL source belongs to its individual library procedures and is separate from this README's version number.
