# DBEDIT2

**README version:** 1.0.0.0.0  
**Date:** 2026-09-04  
**Time:** 20:50:38 UTC  
**Original macro:** dbfEdit Version 1.2 by Peter Birch, dated 1993-02-23

## Description

DBEDIT2 is a legacy macro for The SemWare Editor (TSE) that opens and edits dBASE III database (`.DBF`) records as fixed-length binary lines.

The macro:

- Accepts a database filename and adds `.DBF` when the extension is omitted.
- Recognizes dBASE III files with signature `03h` and dBASE files with an associated memo file (`83h`).
- Reads the DBF header size, record size, and record count.
- Temporarily separates the DBF header from its records.
- Opens the records with the correct fixed line length.
- Updates the record count in the DBF header when records are added or removed.
- Reattaches the header and saves the edited database.

## Archive contents

| File | Description |
| --- | --- |
| `DBEDIT.S` | SAL source code for the database editor macro. |
| `DBEDIT.MAC` | Precompiled legacy macro supplied with the package. |

## Important warning

Do **not** change the length of individual database records while editing. Every record in a DBF file must retain the fixed record length defined in its header. Inserting or deleting characters inside a record can corrupt the database.

Make a backup copy of the database and any related memo file (`.DBT`) before using this macro. Test the result with a disposable copy first. This utility is from 1993 and may not support newer DBF variants or modern TSE versions without modification.

## Requirements

- The SemWare Editor (TSE) with support for SAL macros.
- A dBASE III-compatible `.DBF` file.
- The TSE SAL compiler if `DBEDIT.S` must be recompiled.
- A record length that does not exceed TSE's configured `MaxLineLen` value.

## Installation

1. Extract `dbedit2.zip` into a working directory.
2. Copy `DBEDIT.MAC` to a directory from which TSE can load macros, or keep it in the current working directory.
3. If the supplied compiled macro is incompatible with your TSE version, compile `DBEDIT.S` with the appropriate SAL compiler. For a 32-bit TSE installation, a typical command is:

   ```text
   sc32 DBEDIT.S
   ```

4. Confirm that the compiler creates or updates `DBEDIT.MAC` without errors.

## How to run

1. Back up the `.DBF` file and its matching `.DBT` file, if one exists.
2. Start TSE.
3. Run the macro from TSE, for example by using TSE's macro execution command and specifying:

   ```text
   DBEDIT
   ```

4. At the `Enter database name:` prompt, enter the path and name of the database. The `.DBF` extension may be omitted.
5. Edit the displayed records without changing their fixed lengths.
6. Use one of the following commands:

   | Key | Action |
   | --- | --- |
   | `Ctrl+Z` | Reattach the header, update the record count if necessary, and save/exit. |
   | `Alt+Z` | Abort the editing session without saving the modified database. |

7. When saving, respond to TSE's overwrite prompt for the original database file.
8. Open and validate the saved file in the database application that normally uses it.

## Temporary files

During editing, the macro creates temporary files in the current working directory:

- `<database-name>.HDR` contains the original DBF header.
- `<database-name>.TMP` contains the database records during editing.

These files are normally deleted when the editing session ends. Avoid running two editing sessions for databases with the same base filename in the same directory.

## Troubleshooting

### The database is reported as invalid

The first byte of the file is not `03h` or `83h`. The file may be damaged, may not be a supported dBASE format, or may not be a DBF file.

### The record length is too long

The DBF record length exceeds TSE's `MaxLineLen` setting. Increase the setting only when supported and safe, or use another DBF editor.

### The database cannot be found

Enter a valid path. If no extension is supplied, the macro automatically appends `.DBF`.

### The supplied `DBEDIT.MAC` does not run

It may have been compiled for an older editor version. Recompile `DBEDIT.S` with the SAL compiler belonging to your installed TSE version.

### The saved database is corrupt

Restore the backup immediately. Record corruption can result from changing a record's fixed length, using an unsupported DBF variant, or interrupting the macro before the header and records are recombined.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-04 20:50:38 UTC | Initial Markdown documentation based on `DBEDIT.S` and the contents of `dbedit2.zip`. |

Future documentation revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Disclaimer

Use this program at your own risk. Always retain a verified backup before editing binary database files.
