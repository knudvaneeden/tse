# C_SJPMAC

**README version:** 1.0.0.0.0  
**Date:** 2026-09-04  
**Time:** 22:09:28 CEST  
**Original source date:** 1994-10-02

## Description

`C_SJPMAC.S` is a legacy macro for The SemWare Editor (TSE). It provides a common compile-and-error-navigation interface for several source-file types:

- TSE SAL (`.s`)
- Microsoft QuickBasic (`.qb`, `.qba`, `.qb2`, and `.qbx`)
- C (`.c` and `.h`)
- C++ (`.cpp` and `.hpp`)

The macro determines the compiler from the current file's extension, executes the appropriate DOS command, redirects compiler output to `$error$.tmp`, and opens that file in a second window. Its commands can then move between recognized errors and position the cursor in the source file.

For a successfully compiled SAL macro, C_SJPMAC offers a menu for loading or executing the resulting macro.

The original comments are in French. They explain that QuickBasic messages do not always provide a line number. In that case, the macro extracts text associated with the error and searches for its first occurrence in the source file. This may not always identify the exact line.

## Included file

| File | Purpose |
|---|---|
| `C_SJPMAC.S` | TSE SAL source code for the compiler and error-navigation macro |

## Default keyboard commands

| Key | Action |
|---|---|
| `Ctrl+F9` | Compile the current file |
| `Ctrl+F10` | Go to the next compiler error |
| `Ctrl+F11` | Process the error at the current position |
| `Ctrl+F12` | Go to the previous compiler error |

## Requirements

- A compatible version of The SemWare Editor and its SAL compiler.
- The required language compiler available through the DOS/Windows `PATH`, or its full path entered in `C_SJPMAC.S`.
- Permission to create and delete the temporary file `$error$.tmp` in the current working directory.
- A DOS-compatible environment for the historical QuickBasic and Turbo C commands.

The source uses these compiler commands by default:

| File type | Default compiler command |
|---|---|
| SAL | `sc` |
| QuickBasic | `QB` |
| C and C++ | `tcc` |

## Installation

1. Extract `C_SJPMAC.S` from `c_sjpmac.zip`.
2. Place the source file in your TSE macro source directory.
3. Open `C_SJPMAC.S` in TSE.
4. Review `mCConfigFor()` and change the compiler names or options if they do not match your system.
5. Compile the source with the SAL compiler. For a modern 32-bit TSE installation, this will commonly be:

   ```bat
   sc32 C_SJPMAC.S
   ```

   Older installations may instead use:

   ```bat
   sc C_SJPMAC.S
   ```

6. Load the compiled macro in TSE. The exact compiled filename and loading procedure depend on the TSE version in use.

## How to run

1. Open a supported SAL, QuickBasic, C, or C++ source file in TSE.
2. Save the file if desired. If the current buffer has unsaved changes, the macro saves a temporary source file for compilation.
3. Press `Ctrl+F9`.
4. Wait for the configured compiler to finish.
5. If errors or warnings are recognized, TSE opens `$error$.tmp` in another window and moves to the corresponding location in the source.
6. Use `Ctrl+F10` for the next error, `Ctrl+F11` for the current error, and `Ctrl+F12` for the previous error.
7. When no further errors remain, confirm whether the temporary error file should be deleted.

## Compiler configuration

Compiler settings are defined in the `mCConfigFor()` procedure. Each supported extension configures:

- `comp`: compiler executable
- `comp_opts`: compiler command-line options
- `err_directive`: output-redirection syntax
- `err_file`: temporary compiler-output file
- `err_srch_pat`: pattern identifying error or warning messages
- `err_ln_pat`: pattern identifying a source line number
- `err_col_pat`: pattern identifying a source column number
- `cmd_line`: completed command passed to TSE's `Dos()` command

Edit these values if your compiler executable, command-line options, or diagnostic format differs from the historical defaults.

## Important compatibility notes

- This is historical source code from 1994. Current TSE SAL compilers may report deprecated keywords, undefined symbols, syntax differences, or other compatibility errors.
- The source calls `isChanged()`. Some newer SAL environments may require a different method for detecting whether the current buffer has changed.
- QuickBasic is configured with the historical options `/D /E /F /S /LFSFS.EXE;`. Verify that these options and `FSFS.EXE` exist on your system.
- C and C++ compilation assumes the old Turbo C command `tcc -c`.
- Compiler diagnostics must match the configured regular-expression patterns. Different compiler versions may require updated patterns.
- QuickBasic error navigation searches for text rather than a reliable line number, so repeated words or statements can lead to the wrong location.
- The macro overwrites and deletes files named `$temp$` plus the active extension and `$error$.tmp`. Do not use these names for important files in the working directory.
- The source is stored as legacy extended-ASCII text rather than UTF-8. Preserve a TSE-compatible encoding when editing or compiling it.

## Troubleshooting

### The compiler does not run

Confirm that `sc`, `QB`, or `tcc` is accessible through `PATH`. Otherwise, replace the command in `mCConfigFor()` with the compiler's full pathname.

### The macro reports that the command does not work

Check the generated `cmd_line`, compiler pathname, current working directory, and output-redirection syntax. Also confirm that the directory is writable.

### Compilation succeeds but errors are not detected

The compiler's diagnostic text probably differs from the pattern stored in `err_srch_pat`. Update the search, line-number, and column-number patterns for the compiler version being used.

### The cursor goes to the wrong QuickBasic line

This is a known limitation of the original macro. Because some QuickBasic diagnostics do not contain line numbers, C_SJPMAC searches for the first occurrence of the reported text.

### Keyboard shortcuts conflict with other macros

Change the four key definitions at the end of `C_SJPMAC.S`, recompile the macro, and load it again.

## Version history

| Version | Date | Description |
|---|---|---|
| 1.0.0.0.0 | 2026-09-04 | Initial Markdown documentation created from `c_sjpmac.zip`. |

Future documentation revisions should increment the final component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Disclaimer

This README documents the supplied historical source as found. The program has not been modernized, and compiler behavior can vary according to the TSE and external compiler versions installed.
