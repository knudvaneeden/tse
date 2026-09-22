# MFFND58 - MFFind 5.8

Version: 1.0.0.0.2  
Updated: 2026-09-22 12:03:24 UTC  
Prepared with: OpenAI Codex

## Description

MFFind 5.8 is a multi-file search, replace, navigation, and line-processing macro suite for The SemWare Editor (TSE). It works across files currently loaded in TSE's buffer ring and creates a hit list from which matching locations can be revisited.

The supplied source is the original MFFind 5.8 multi-module program for TSE Pro 2.50a, updated in this package with:

- an informative startup message in `Main()`;
- a `silent` setting in `mffnd58.ini`;
- ASCII source files suitable for the TSE SAL toolchain;
- this installation and usage guide.

## Main features

- Find a string in all loaded files.
- Find the word under the cursor.
- Use TSE regular expressions.
- Find functions in recognized source-file types.
- Find blank, duplicate, matching, non-matching, and C/C++ comment lines.
- Replace text across all loaded files.
- Delete selected categories of lines across loaded files.
- Review results in a hit-list buffer.
- Move to the next or previous hit.
- Configure histories, progress messages, screen updates, replacement verification, fill characters, and custom file definitions.

## Package contents

- `MFFIND.S` - main module, menu, key assignments, and startup message.
- `MFFIND2.S` through `MFFIND6.S` - supporting program modules.
- `MFFIND.INC` and `MFFIND2.INC` - shared declarations and procedures.
- `mffnd58.ini` - startup and MFFind configuration.
- `MAKE_MFF.BAT` - original DOS/Windows batch compiler helper.
- `mffnd58_readme.md` - this file.

## Important compatibility note

MFFind 5.8 dates from 1995 and targets TSE Pro 2.50a. Compile every supplied `.s` file with the same modern TSE SAL compiler that will run the macros. Old `.MAC` files should not be mixed with newly compiled modules and may not work in newer TSE versions. This package therefore supplies source and no precompiled `.MAC` files.

Back up open files before using multi-file replacement or deletion commands. Test the macro on copies first.

## Installation and compilation

1. Extract all files from `mffnd581.0.0.0.2.zip` into one directory.
2. Keep all `.s`, `.inc`, and `.ini` files together during compilation.
3. Open a command prompt in that directory.
4. Compile all six SAL source modules with your TSE SAL compiler. For example:

   ```bat
   sc32 MFFIND.S MFFIND2.S MFFIND3.S MFFIND4.S MFFIND5.S MFFIND6.S
   ```

   Alternatively, adapt `MAKE_MFF.BAT` if your compiler command is not `sc`.

5. Confirm that `MFFIND.MAC` through `MFFIND6.MAC` were created without errors in the same directory as the source files.
6. MFFind first searches the directory containing the running `MFFIND.MAC` for `MFFIND2.MAC` through `MFFIND6.MAC`. During a source compile/run test it also checks the directory containing the current source file. As a final compatibility fallback, it uses TSE's normal macro search path.
7. Keep `MFFIND.MAC` through `MFFIND6.MAC` and `mffnd58.ini` together in that directory. The INI loader uses the same local-directory lookup order before falling back to `TSEPath`. If the INI file is absent, MFFind creates it in the main macro directory or current source directory with `silent=false`.
8. Do not retain older MFFind `.MAC` modules in another earlier directory on `TSEPath`, because the fallback search might load a mismatched copy.
9. Restart TSE or purge older loaded MFFind modules before loading the newly compiled version.

## Startup-message setting

The `[Startup]` section of `mffnd58.ini` contains:

```ini
[Startup]
silent=false
```

- `silent=false` is the package default and shows the informative `Warn()` box whenever the user directly runs `MFFIND`.
- `silent=true` suppresses that startup box and opens the MFFind menu immediately.

Keep the setting exactly in the form `silent=true` or `silent=false`.

## How to run

1. Load several files into TSE; MFFind processes files in the current buffer ring.
2. Run the main macro:

   ```text
   MFFIND
   ```

3. With the default `silent=false`, read and dismiss the startup information box.
4. Choose an operation from the MFFind menu.
5. Enter the requested search text, replacement text, options, or confirmation.
6. Review the generated hit list. Put the cursor on a hit and press `Enter` to visit it.
7. Use **Next Hit** or **Previous Hit** to navigate without reopening the hit list.
8. Save changed files only after reviewing the results.

Run only `MFFIND` directly. `MFFIND2` through `MFFIND6` are internal supporting modules and normally warn if executed directly.

## Default key assignments

The original key definitions include:

- `Alt+V`, then `V`: show the MFFind menu.
- `Alt+V`, then `F`: find a string.
- `Alt+V`, then `W`: find the current word.
- `Alt+V`, then `C`: find functions.
- `Alt+V`, then `L`: find-lines menu.
- `Alt+V`, then `R`: replace.
- `Alt+V`, then `D`: delete-lines menu.
- `Alt+V`, then `A`: show the hit list again.
- `Alt+V`, then `N`: next hit.
- `Alt+V`, then `P`: previous hit.
- `Alt+V`, then `U`: configure MFFind.
- `Alt+V`, then `H`: help.
- `Alt+Shift+1`: previous hit.
- `Alt+Shift+2`: next hit.

Key availability can depend on the TSE user-interface configuration and other loaded macros. Change the `KEYDEF` section near the end of `MFFIND.S` and recompile if a key conflicts.

## Configuration

Use **Configure MFFind** to change operational settings. The INI file also provides up to ten custom file-extension/search-expression pairs under `[Custom File Definitions]`.

The startup `silent` option controls only the newly added informative message. It does not suppress MFFind error messages, confirmations, search prompts, or safety warnings.

## Troubleshooting

### MFFIND2.MAC through MFFIND6.MAC cannot be loaded

Compile every `.s` module and keep all six `.MAC` files in the same macro-search location. Remove or relocate stale copies.

### The startup message still appears

Check that the active file is named `mffnd58.ini`, is beside the macros or otherwise discoverable through `TSEPath`, and contains `silent=true` on one line without extra spaces.

### No files are searched

Load the target files into TSE before starting the operation. MFFind searches the files in TSE's buffer ring rather than recursively scanning a disk directory.

### Compilation errors occur in a modern TSE release

This is legacy TSE Pro 2.50a SAL source. Compile all modules together with one compiler version and address reported language-compatibility differences in the source; do not substitute old `.MAC` files from a different TSE release.

## Version history

- 1.0.0.0.2 - 2026-09-22 12:03:24 UTC - Find `mffnd58.ini` beside the main macro or current source file; create the default INI there when missing.
- 1.0.0.0.1 - 2026-09-22 11:59:16 UTC - Load supporting `.MAC` modules from the directory containing the main macro or current source file before falling back to `TSEPath`.
- 1.0.0.0.0 - 2026-09-22 11:47:10 UTC - Initial repackaging of MFFind 5.8 with documentation, `mffnd58.ini`, and a configurable startup information box.
