# DIRLIST — Directory Listing Macro for TSE Pro/32

**README version:** 1.0.0.0.0  
**Date:** 2026-09-05  
**Time:** 00:20:06 CEST (UTC+02:00)  
**Original program date:** 1999-09-21  
**Original author:** Jose Adriano Baltieri  
**Original email:** jabaltie@iep-cen.unimep.br

## Description

DIRLIST is a SemWare Editor (TSE) Pro/32 SAL macro that creates a directory listing in a new editor buffer. It can list files from a selected path and optionally recurse through subdirectories.

For every listed item, the macro can add:

- Date
- Time
- File size
- File attributes
- Custom prefix text
- Custom suffix text

The fields may be selected in any order. This makes DIRLIST useful for preparing file inventories, reports, command lists, and maintenance batch files.

The supplied archive contains:

| File | Description |
| --- | --- |
| `DIRLIST.S` | SAL source code for the macro |
| `DIRLIST.MAC` | Precompiled TSE Pro/32 macro |
| `FILE_ID.DIZ` | Original short package description |

## Requirements

- The SemWare Editor Professional (TSE Pro/32)
- The TSE SAL compiler if you want to rebuild `DIRLIST.MAC` from `DIRLIST.S`
- The `LONGSTLN` macro, because DIRLIST runs `ExecMacro("longstln")` while aligning suffix text

The original package identifies the macro as being for TSE Pro/32 version 2.8. Compatibility with newer TSE versions may depend on support for the older SAL syntax and the availability of `LONGSTLN`.

## Installation

### Option 1 — Use the supplied compiled macro

1. Extract `dirlist.zip` into a temporary directory.
2. Copy `DIRLIST.MAC` to your TSE macro directory.
3. Make sure `LONGSTLN.MAC` is installed and available to TSE.
4. Start or restart TSE if necessary.

### Option 2 — Compile the SAL source

1. Extract `dirlist.zip`.
2. Open a command prompt in the extracted directory.
3. Compile the source with the TSE SAL compiler:

   ```bat
   sc32 DIRLIST.S
   ```

4. If compilation succeeds, copy the resulting `DIRLIST.MAC` to your TSE macro directory.
5. Make sure `LONGSTLN.MAC` is also installed.

If `sc32` is not in your `PATH`, run it using its complete path or compile the source through your normal TSE SAL build setup.

## How to run DIRLIST

1. Start TSE Pro/32.
2. Open the TSE macro execution prompt or macro menu.
3. Run:

   ```text
   dirlist
   ```

4. Complete the questions shown by the macro.
5. DIRLIST creates a new unsaved editor buffer containing the generated listing.
6. Review the result and save the buffer manually if you want to keep it.

## Prompt reference

### 1. Path for directory listing

Enter a directory and file mask. The default is the current directory followed by `*.*`.

Examples:

```text
C:\SOURCE\*.*
C:\SOURCE\*.S
*.TXT
```

A path beginning with `\` uses the drive of TSE's current directory. A relative path is resolved from the current directory.

### 2. Recurse into subdirectories

Choose **Yes** to scan matching files in the selected directory and its subdirectories. Choose **No** to scan only the selected directory.

### 3. Include directory entries

Choose **Yes** if directory names should also appear in the output. Choose **No** to list files only.

### 4. Date, time, size, and attributes

Enter zero or more of the following letters. Their order determines the order of the fields in each output line.

| Letter | Field |
| --- | --- |
| `D` | File date |
| `T` | File time |
| `S` | File size |
| `A` | File attributes |

Examples:

```text
DTSA
SDT
A
```

Leave the answer empty if no metadata fields are required.

Attribute letters used in the output are:

| Letter | Meaning |
| --- | --- |
| `n` | Normal |
| `r` | Read-only |
| `h` | Hidden |
| `s` | System |
| `v` | Volume |
| `d` | Directory |
| `a` | Archive |

### 5. Additional prefix

Enter text to place before every pathname. This is useful for constructing commands.

Example:

```text
git add
```

### 6. Additional suffix

Enter text to append to every output line. DIRLIST aligns the suffix after the longest generated line.

Example:

```text
REM reviewed
```

## Example use

To produce a recursive listing of all SAL source files under `C:\TSE\MACROS`, including date, time, and size:

```text
Path:                C:\TSE\MACROS\*.S
Recurse:             Yes
Include directories: No
Fields:              DTS
Prefix:              (leave empty)
Suffix:              (leave empty)
```

To prepare command lines, use a prefix such as:

```text
git add
```

The resulting buffer can then be reviewed and edited before being saved or executed as a batch file.

## Notes and limitations

- The generated buffer is not saved automatically.
- File paths are converted to uppercase by the original macro.
- Date output is reformatted by the macro to a year/month/day-style numeric order based on the date string returned by TSE.
- The suffix-alignment step depends on the `LONGSTLN` macro.
- The source is from 1999 and uses legacy SAL syntax.
- The original package also mentions that a DOS/TSE 2.5 version existed, but that version is not included in this archive.

## Troubleshooting

### `LONGSTLN` cannot be found

Install `LONGSTLN.MAC` in a directory where TSE can find and execute macros. DIRLIST needs it to determine the longest output line before adding suffix text.

### No files are listed

- Check that the directory exists.
- Check the filename mask, such as `*.*`, `*.S`, or `*.TXT`.
- Confirm that TSE's current drive and directory are what you expect when using a relative path.
- Try a complete absolute path.

### The macro does not appear in TSE

- Confirm that `DIRLIST.MAC` is in the correct TSE macro directory.
- Restart TSE or reload the macro according to your TSE configuration.
- Try running the macro by entering `dirlist` in the macro execution prompt.

### The source does not compile

- Confirm that you are using the SAL compiler for TSE Pro/32.
- Keep the source in an ASCII-compatible format because it predates Unicode-oriented workflows.
- Older SAL syntax may require adjustments when compiling with a substantially newer TSE release.

## Version history

| Version | Date | Description |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-05 | Initial Markdown documentation created from `DIRLIST.S`, `DIRLIST.MAC`, and `FILE_ID.DIZ`. |

Future documentation revisions should increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## License and attribution

No explicit software license is included in the archive. The source header invites users to improve the macro and asks them to inform the original author about interesting changes. Preserve the original author attribution when redistributing or modifying the program.
