# COBOL Macros for The SemWare Editor (TSE)

**README version:** 1.0.0.0.1  
**Date:** 2026-09-02  
**Time:** 22:21:43 UTC  
**Original macro date:** 2002-12-06  
**Original author:** Carlo Hogeveen

## Description

`cobol.zip` contains three cooperating TSE Pro SAL macros that provide COBOL-aware tabbing and backspacing:

- `settabs2.s` temporarily selects suitable variable tab stops for a COBOL source file or copybook.
- `tab2.s` provides smart Tab and Shift+Tab handling for the cursor or a marked line/column block.
- `bakspac2.s` provides smarter Backspace behavior based on the active tab positions and surrounding white space.

The macros recognize normal COBOL source files by the extensions `.cbl` and `.cob`. A file whose name begins with `cpy` is also treated as a COBOL copybook, regardless of its extension.

## Files in the archive

| File | Purpose |
| --- | --- |
| `tab2.s` | Implements smart Tab and Shift+Tab and binds the relevant keys. |
| `settabs2.s` | Selects, installs, and later restores variable tab settings. |
| `bakspac2.s` | Implements smart Backspace behavior and COBOL copybook handling. |
| `file_id.diz` | Original short package description. |

## Main features

### COBOL-aware tab stops

`settabs2.s` uses different tab-stop definitions for:

- the COBOL Data Division;
- the COBOL Procedure Division;
- general COBOL source;
- COBOL copybooks.

It searches the current file for division declarations and chooses the appropriate tab layout. If TSE was already using smart tabs, it can combine detected indentation positions with the configured COBOL positions.

The original tab settings are saved before the operation and restored afterward, so the macros do not permanently replace the editor's normal tab configuration.

### Smart Tab and Shift+Tab

`tab2.s` defines:

```text
<Tab>       ExecMacro("tab2 Right")
<Shift Tab> ExecMacro("tab2 left")
<BackSpace> ExecMacro("Bakspac2")
```

For an ordinary cursor position, Tab moves right and Shift+Tab moves left. For a marked line or column block, the macro can shift the marked text to the next or previous suitable tab position.

For line blocks in `.cbl` and `.cob` files, the working block begins at COBOL column 8 so that the traditional sequence area is protected.

### Smart Backspace

`bakspac2.s` behaves like a normal Backspace when appropriate, but within white space it can remove indentation back to a preceding configured tab position. At the start of a non-first line, it joins the line to the previous line.

Special copybook handling is included near the configured picture position (column 42).

## Requirements

- The SemWare Editor Professional (TSE Pro) with SAL macro support.
- The SAL compiler supplied with TSE, normally `sc32.exe`.
- All three macro source files available to TSE at runtime.

These are legacy macros from 2002. Depending on the installed TSE version, minor source changes may be needed if a keyword, key name, or compiler rule has changed.

## Installation

1. Extract `cobol.zip` into a directory used for TSE SAL macros.
2. Open a command prompt in that directory.
3. Compile all three source files:

   ```bat
   sc32 settabs2.s
   sc32 bakspac2.s
   sc32 tab2.s
   ```

4. Confirm that TSE created the corresponding compiled macro files.
5. Make sure the compiled macros are stored in a directory where TSE can find and execute them.
6. Add `tab2` and `bakspac2` to TSE's Macro AutoLoadList so their key definitions are active whenever TSE starts.
7. Restart TSE or load the compiled macros manually.

`settabs2` does not normally need to be added to the AutoLoadList. It is called internally by `tab2` and `bakspac2`.

## How to run

1. Open a COBOL file with the extension `.cbl` or `.cob`, or open a copybook whose filename begins with `cpy`.
2. Press **Tab** to move or shift text to the next selected COBOL tab position.
3. Press **Shift+Tab** to move or shift text to the preceding tab position.
4. Press **Backspace** to remove text or indentation using the smart Backspace rules.
5. Mark a line or column block before pressing Tab or Shift+Tab if multiple lines should be shifted together.

After installation, the normal way to use the package is through these keys. It is not necessary to run `settabs2` directly.

## Manual macro commands

The following commands are used internally and may also be useful for testing:

```text
ExecMacro("tab2 Right")
ExecMacro("tab2 left")
ExecMacro("bakspac2")
ExecMacro("settabs2 set")
ExecMacro("settabs2 reset")
```

Always balance `settabs2 set` with `settabs2 reset`; otherwise the temporary tab configuration may remain active.

## Customizing the COBOL tab positions

The tab layouts are defined near the beginning of `settabs2.s`:

```text
data_division_tabs
procedure_division_tabs
general_tabs
```

Edit their space-separated column numbers to match the COBOL layout used at your site, then recompile `settabs2.s`.

The original archive explicitly notes that these tab settings may need to be adjusted. Test changes on sample COBOL files before adopting them for regular work.

The copybook picture-position behavior is controlled by this definition in `bakspac2.s`:

```text
#define picture_position 42
```

Change it only if the copybook layout used at your site places picture clauses elsewhere, then recompile `bakspac2.s`.

## Troubleshooting

### Tab or Backspace still uses TSE's normal behavior

- Confirm that `tab2` and `bakspac2` are loaded.
- Confirm that both macros are present in the Macro AutoLoadList.
- Check whether another loaded macro assigns the same keys later and overrides these definitions.

### TSE cannot execute `settabs2`

- Compile `settabs2.s` as well as the other two source files.
- Store all three compiled macros where TSE can locate them.
- Keep the original base filenames because the macros call one another by name.

### The wrong tab positions are selected

- Confirm that the file extension is `.cbl` or `.cob`, or that a copybook filename begins with `cpy`.
- Check the spelling and format of the Data Division or Procedure Division declaration.
- Adjust the three tab-definition strings in `settabs2.s` for the local COBOL standard.

### Compiling produces errors on a newer TSE release

The package is legacy SAL code. Review compiler messages for renamed or reserved identifiers, deprecated syntax, or changed key names. Make one compatibility change at a time and recompile all affected macros.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 22:21:43 | Initial README structure and package description. |
| 1.0.0.0.1 | 2026-09-02 22:21:43 | Added installation, operation, customization, manual-command, and troubleshooting details after reviewing all files in `cobol.zip`. |

## License

No explicit license file is included in `cobol.zip`. Retain the original author attribution and package information, and obtain permission from the rights holder before redistributing modified versions when required.
