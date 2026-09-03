# COMPMAC — Compile Macro for The SemWare Editor

**README version:** 1.0.0.0.0  
**Date:** 2026-09-03  
**Time:** 18:33:39 Europe

## Description

`C_MACS.S` is a legacy SAL macro for The SemWare Editor (TSE). It compiles the file in the current editor window, captures compiler messages in a temporary error file, and lets the user move through reported errors and warnings.

The supplied configuration supports:

- SAL source files (`.s`) using `sc`.
- C source and header files (`.c` and `.h`) using `tcc -c`.
- C++ source and header files (`.cpp` and `.hpp`) using `tcc -c`.

For a SAL file that compiles successfully, the macro displays a menu from which the compiled macro can be loaded or executed. For C files, it reports successful compilation. When errors or warnings are found, the source cursor is moved to the corresponding line and, when available, column.

## Included file

- `C_MACS.S` — source code for the compile-and-error-navigation macro.

## Default keys

| Key | Action |
|---|---|
| `Ctrl+F5` | Compile the file in the current editor window. |
| `Ctrl+F6` | Find the next compiler error or warning. |

## Requirements

- The SemWare Editor with a compatible SAL compiler.
- The required compiler available through the system `PATH`, or its full path entered in `C_MACS.S`.
- Write permission in the current working directory because the macro uses `$error$.tmp` and, for an unsaved changed buffer, `$temp$` plus the current extension.

The original macro calls the older compiler commands `sc` and `tcc`. On a newer TSE installation, the SAL compiler may instead be named `sc32`. Configure the command names and options before use if they differ on your computer.

## Installation

1. Extract `compmac.zip` to a working directory.
2. Copy `C_MACS.S` to your TSE macro source directory, or open it directly from its extracted location.
3. Review `mCConfigFor()` in `C_MACS.S`.
4. Change `comp`, `comp_opts`, `err_directive`, `err_file`, and the error-search patterns when necessary for your compiler versions.
5. Compile the macro with the SAL compiler appropriate for your TSE version. For example:

   ```bat
   sc32 C_MACS.S
   ```

6. Confirm that the compiled macro file was created successfully.
7. Load the compiled macro in TSE, or add it to your normal macro-loading configuration.

## How to run

1. Open a supported `.s`, `.c`, `.h`, `.cpp`, or `.hpp` file in TSE.
2. Press `Ctrl+F5`.
3. The macro saves a changed buffer temporarily, builds the compiler command line, and runs the compiler.
4. If compilation succeeds for a SAL file, choose **Load macro** or **Execute macro** from the displayed menu.
5. If an error or warning is reported, TSE opens `$error$.tmp` in a second window and moves the source cursor to the detected location.
6. Press `Ctrl+F6` repeatedly to visit subsequent errors or warnings.
7. After the final message, answer the prompt to remove the temporary error file and close its window.

## Configuration details

Compiler settings are selected in `mCConfigFor()` according to the current filename extension. Each configuration supplies:

- Compiler command and options.
- Output-redirection syntax.
- Temporary error filename.
- Regular-expression pattern for locating errors and warnings.
- Regular-expression patterns for extracting line and column numbers.

Add another `when` section to `mCConfigFor()` to support an additional language or compiler. Its diagnostic patterns must match the exact text produced by that compiler.

## Important notes

- This is old SAL source dated 1993 and may require syntax or API adjustments for a current TSE SAL compiler.
- The error parser depends on the original output formats of `sc` and `tcc`. Modern compiler messages may not match its regular expressions.
- The macro redirects compiler output with `>`; a compiler that writes diagnostics only to standard error may require different redirection.
- The `.cpp`/`.hpp` success branch is empty in the supplied source, so no success message is displayed for those extensions.
- If the current buffer contains unsaved changes, the macro compiles a temporary copy rather than overwriting the original source file.
- Back up the source before modifying its configuration.

## Troubleshooting

### The macro says that the command did not work

- Verify that the compiler executable is installed and available through `PATH`.
- Replace `sc` or `tcc` with the correct full compiler path if necessary.
- Run the generated compiler command manually in a command prompt to check it.

### Compilation succeeds but is treated as an error

- Inspect `$error$.tmp`.
- Adjust `err_srch_pat`, `err_ln_pat`, and `err_col_pat` to match the compiler's actual output.

### The cursor moves to the wrong place

- Check the diagnostic line and column format.
- Correct `err_ln_pos` and `err_col_pos` if the extracted number begins at a different character position.

### A key does not work

- Check whether another loaded macro already defines `Ctrl+F5` or `Ctrl+F6`.
- Change the key definitions at the end of `C_MACS.S`, recompile, and reload the macro.

## Version history

| Version | Date | Time | Changes |
|---|---|---|---|
| 1.0.0.0.0 | 2026-09-03 | 18:33:39 Europe | Initial README created from the supplied `compmac.zip` archive and `C_MACS.S` source. |

Future revisions should increment the last component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.
