# Filebase for TSE Pro

**README version:** 1.0.0.0.0  
**Date:** 2026-09-07  
**Time:** 20:07:13 CEST (18:07:13 UTC)  
**Original macro date:** February/March 2000  
**Original author:** Helmut Geisser, Loewe Opta GmbH

## Description

Filebase is an autoload macro for **The SemWare Editor Professional (TSE Pro) 2.5 for DOS**. It remembers the editing position of every file and restores that position when the file is opened again.

For each file, the macro records:

- Current line
- Cursor row on the screen
- Cursor position within the line
- Horizontal scroll offset

The saved positions are stored in `tsebase.dat` in the macro load directory. Entries that point to the first line, first column and zero horizontal offset are removed when TSE exits, keeping the database smaller.

## Package contents

| File | Purpose |
| --- | --- |
| `FILEBASE.S` | Main Filebase autoload macro |
| `SYMTAB.S` | Required symbol-table include used by `FILEBASE.S` |
| `FILE_ID.DIZ` | Original short package description |

## Requirements

- TSE Pro 2.5 for DOS, as stated in the original package
- The TSE SAL compiler appropriate for that TSE installation
- `FILEBASE.S` and `SYMTAB.S` placed together in the same macro source/load directory
- Write access to the macro load directory so `tsebase.dat` can be created and updated

## Installation and compilation

1. Extract `filebase.zip` to a temporary directory.
2. Copy `FILEBASE.S` and `SYMTAB.S` into your TSE macro source directory.
3. Open a DOS command prompt in that directory.
4. Compile the main source file with the SAL compiler used by your TSE installation. A typical command is:

   ```dos
   sc FILEBASE.S
   ```

   If your installed compiler has a different executable name, use that name instead.

5. Confirm that compilation completes without errors and produces the compiled Filebase macro.
6. Add the compiled Filebase macro to TSE's **AutoLoad List** using TSE's macro configuration or macro manager.
7. Restart TSE so the autoload macro is initialized.

## How to run it

Filebase is not intended to be started manually for normal use. Once it is in the AutoLoad List, it works automatically:

1. Open a file in TSE.
2. Move the cursor to another line or column, and optionally scroll horizontally.
3. Close the file or exit TSE normally.
4. Start TSE again and reopen the same file.
5. Filebase restores the previously saved editing position.

The macro also restores the remembered position when an already known file receives its first edit event during a session.

## Data file

Filebase creates and maintains:

```text
tsebase.dat
```

This file is stored in the directory returned by TSE's `LoadDir()` function. Do not edit it manually while TSE is running. To reset all remembered positions, exit TSE completely and then rename or remove `tsebase.dat`. A new database will be created the next time the macro runs.

## Help and troubleshooting

### The cursor position is not restored

- Verify that Filebase is present in the AutoLoad List.
- Restart TSE after installing or recompiling the macro.
- Confirm that `SYMTAB.S` was available when `FILEBASE.S` was compiled.
- Exit TSE normally so the current positions can be written to `tsebase.dat`.
- Check that TSE can write to its macro load directory.

### Compilation reports that `symtab.s` cannot be found

Place `SYMTAB.S` in the same source/load directory as `FILEBASE.S`, or configure the compiler's include path so it can locate the file. The source contains:

```sal
#include ["symtab.s"]
```

### The database appears invalid or old positions are ignored

The source expects the internal database identifier `TSE File Base 20000224`. If the identifier in `tsebase.dat` differs, Filebase discards the old symbol table and creates a new one. Exit TSE, back up or remove `tsebase.dat`, and restart TSE if a clean reset is needed.

### Long filenames do not work

The original package explicitly states that long filename support is unavailable. It was designed for TSE Pro 2.5 for DOS and uses an 80-character path buffer. Use DOS-compatible paths and filenames.

### Compatibility with newer TSE versions

This is historical SAL source from 2000. Newer TSE versions or Windows editions may require source changes, a different compiler command, or adaptations for path handling and character encoding. Test it on copies of non-critical files before relying on it.

## Uninstalling

1. Remove Filebase from TSE's AutoLoad List.
2. Restart or exit TSE.
3. Delete the compiled Filebase macro if no longer required.
4. Optionally delete `tsebase.dat` to remove all saved file positions.
5. Keep `SYMTAB.S` if another macro uses it.

## Version history

| README version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-07 | Initial README created from the supplied `filebase.zip` package. |

Future documentation revisions should increment the final component, for example: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Notes

- Filebase stores normalized paths with backslashes.
- Symbol-table entries are limited by the SAL string-size restrictions documented in `SYMTAB.S`.
- The original software and author information remain credited to the source package.
