# CHDIR for TSE — DLL edition

**Version:** 1.0.0.0.1  
**Created:** 2026-09-02 00:02:10 CEST  
**Updated:** 2026-09-02 CEST  
**Target:** 32-bit TSE and Borland C++ 5.5/5.5.1

## Description

This edition replaces the obsolete TSE UI binary dependency:

```text
binary '??:\tse\ui\wp.bin'
```

with a standalone 32-bit Windows DLL named `chdirdll.dll`.

The SAL macro asks for a directory, calls the DLL to change TSE's process current directory, and opens TSE's file-selection dialog in that directory. If Windows rejects the path, the macro displays the numeric Windows error code.

## Package files

| File | Purpose |
| --- | --- |
| `chdir.s` | Updated TSE SAL macro |
| `chdirdll.c` | Borland C source for the DLL |
| `chdirdll.def` | Exports the stable entry point `CHDIR` |
| `build.bat` | Builds the 32-bit DLL with Borland C++ 5.5 |
| `chdir_readme.md` | This documentation |

## Interface

The SAL declaration is:

```text
dll "chdirdll.dll"
    integer proc PASCAL ChDirDll(string directoryS : cstrval) : "CHDIR"
end
```

- `PASCAL` selects TSE's Pascal DLL calling convention.
- `CSTRVAL` passes a temporary null-terminated string to C.
- The DLL function uses Borland's `__pascal` convention to match TSE's declaration.
- `chdirdll.def` exports the entry point as the undecorated name `CHDIR`, avoiding compiler-specific decorated names.
- The function returns `0` on success or a Windows error code on failure.

TSE supports only 32-bit DLLs, so do not rebuild this DLL as 64-bit.

## Requirements

- Borland C++ command-line compiler 5.5 or 5.5.1
- A working `bcc32.cfg` containing the correct Borland include and library paths
- 32-bit TSE with the SAL compiler (`sc32.exe`)

Example `bcc32.cfg` for a compiler installed under `G:\language\computer\cpp\embarcadero\borland\bcc55`:

```text
-IG:\language\computer\cpp\embarcadero\borland\bcc55\include
-LG:\language\computer\cpp\embarcadero\borland\bcc55\lib
```

Adjust these paths for your installation.

## Build the DLL

1. Extract the ZIP into a directory.
2. Open a command prompt in that directory.
3. Make sure the Borland `bin` directory is in `PATH`, or run the batch file from the Borland `bin` directory while supplying the package path as your current directory.
4. Run:

   ```bat
   build.bat
   ```

5. A successful build ends with:

   ```text
   Build completed: chdirdll.dll
   ```

The build is deliberately split into compilation and linking steps. The C function is named `CHDIR` and uses Borland's `__pascal` keyword; the linker definition file publishes that stable uppercase entry point.

## Install and compile the SAL macro

1. Copy `chdirdll.dll` to the same directory as `chdir.mac`, or to a directory where TSE searches for macros.
2. Open `chdir.s` in TSE.
3. Compile it from TSE, or run:

   ```bat
   sc32 chdir.s
   ```

4. Confirm that `chdir.mac` was created.
5. Load or execute `chdir.mac` using TSE's normal macro command.

No hard-coded TSE installation path is required. Because the DLL name is enclosed in ordinary quotation marks, TSE searches for it using its macro search method.

## How to run

1. Execute `chdir.mac`; its `Main()` procedure calls the public `mChDir` procedure. You can also assign `mChDir` directly to a key.
2. Enter a directory such as:

   ```text
   G:\language\computer\cpp
   ```

3. Press **Enter**.
4. TSE changes its current directory and opens the file-selection dialog.

Press **Escape** to cancel the prompt.

## Supported path examples

```text
C:\WORK\SOURCE
..\OTHER
\TEMP
G:\
```

The updated macro uses a 255-character SAL string instead of the original 40-character path buffer.

## Common Windows error codes

| Code | Meaning |
| ---: | --- |
| 2 | File not found |
| 3 | Path not found |
| 5 | Access denied |
| 87 | Invalid parameter |
| 206 | Filename or path is too long |

## Troubleshooting

### TSE cannot load `chdirdll.dll`

- Confirm that the DLL is beside `chdir.mac` or in TSE's macro search path.
- Confirm that the DLL is the 32-bit build produced by BCC32.
- Do not register the DLL with `regsvr32`; it is a normal native DLL, not a COM server.

### TSE cannot find `CHDIR`

- Rebuild using the supplied `chdirdll.def` file.
- Inspect the DLL exports with an export viewer and confirm that the name is exactly `CHDIR`.
- Ensure the linker command completed without export warnings.

### The SAL compiler rejects the declaration

The expected declaration order is:

```text
integer proc PASCAL ChDirDll(string directoryS : cstrval) : "CHDIR"
```

The `dll ... end` block must occur before the macro procedure that calls it.

### Rebuilding does not appear to change behavior

TSE can keep a loaded DLL in memory. Exit all running TSE instances, rebuild or replace `chdirdll.dll`, and restart TSE.

## Version history

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 | Initial Markdown documentation for the original `wp.bin`-based macro. |
| 1.0.0.0.1 | 2026-09-02 | Replaced `wp.bin` with a standalone BCC55-compatible 32-bit DLL; added Pascal-style SAL interface, error reporting, build script, and 255-character path input. |

Future revisions increment the final component: `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Credits

The original 1994 `chdir.txt` macro identifies Walter Metcalf as its author. The DLL adaptation and expanded documentation were prepared with OpenAI Codex (GPT-5).
