# LLIST_32

## Session name

`Create LLIST_32 MarkDown Readme`

## README version

`1.0.0.0.0`

## Last updated

`2026-09-14 22:02:53 UTC`

## Description

LLIST_32 is a TSE SAL macro package containing `LOADLIST.S`, version 3.2. The macro was written by Ray Asbury and compiled for The SemWare Editor (TSE) 2.00.

`LOADLIST.S` loads a collection of files whose names are stored in the current text file. The list may contain ordinary filenames, full DOS paths, relative paths, and DOS wildcard specifications. Individual files can also be excluded from the final set.

After processing the list, the macro:

1. Removes any explicitly excluded files from the editor.
2. Abandons the list-file buffer.
3. Switches to the first file that was loaded.
4. Purges the `LOADLIST` macro from memory.

## Files in the archive

| File | Description |
| --- | --- |
| `LOADLIST.S` | TSE SAL source code for the LoadList macro, original version 3.2 dated 1994-09-16. |

## List-file format

Place one or more file specifications in a plain-text file. Entries may be separated by spaces, tabs, or blank lines. The macro converts the entries internally so that each specification is processed separately.

Supported entries include:

- A filename in the current directory, such as `README.TXT`.
- A relative path, such as `.\SOURCE\*.S` or `..\DOCS\*.TXT`.
- A full DOS or Windows path, such as `C:\CONFIG.SYS`.
- DOS wildcards `*` and `?` for files that must be loaded.
- A filename prefixed with `-` for a file that must be excluded.

Example list file:

```text
*.S
README.*
.\*.ASC
..\..\*.AS?
C:\AUTOEXEC.BAT
C:\CONFIG.SY?
D:.\*.ASC
-D:.\FIRST.ASC
```

The order of include and exclude entries does not matter. An excluded file is removed after all included files have been loaded.

## Important restrictions

- An exclusion entry must identify a specific file.
- Do not use `*` or `?` in an exclusion entry.
- An invalid wildcard exclusion produces a warning; press **Escape** to dismiss the warning and continue.
- If a base filename matches more than one extension in TSE's `DefaultExt` setting, only the file matching the first applicable extension may be loaded.
- The list file is abandoned after processing. Save the list file before running the macro if it contains changes you want to keep.
- This is legacy source code written for TSE 2.00. Test it on a copy of your data before using it with a newer TSE release.

## Compilation

Compile the source with the TSE SAL compiler:

```bat
sc32 LOADLIST.S
```

If compilation succeeds, the compiler creates:

```text
LOADLIST.MAC
```

Make sure `LOADLIST.MAC` is in a directory from which TSE can load or execute macros.

## How to run it from inside TSE

1. Create a plain-text list file containing the files to load.
2. Save the list file.
3. Open that list file in TSE.
4. Make sure the list file is the current file.
5. Execute the compiled `LOADLIST` macro using TSE's macro execution facility.
6. Wait while the status line reports the files being loaded.
7. After processing, TSE closes the list-file buffer and displays the first file that was loaded.

## How to run it from the command line

The original source recommends starting TSE with the list file and using the `/E` option to execute the macro automatically:

```bat
g32.exe myfiles.lst /Eloadlist
```

For a TSE installation whose executable is named `e32.exe`, use:

```bat
e32.exe myfiles.lst /Eloadlist
```

Replace `myfiles.lst` with the actual path and name of your list file.

## Example workflow

Create `project.lst`:

```text
C:\PROJECT\*.S
C:\PROJECT\*.INC
-C:\PROJECT\OLD.S
```

Then run:

```bat
g32.exe project.lst /Eloadlist
```

This loads matching `.S` and `.INC` files, removes `OLD.S` if it was loaded, closes `project.lst`, and moves to the first loaded file.

## Troubleshooting

### No files are loaded

- Confirm that the list file is the current file before executing the macro.
- Check that the paths are valid from the working location used by TSE.
- Verify that the requested files exist.
- Check the spelling of filenames and directory names.

### A file cannot be excluded

- Remove wildcards from the exclusion entry.
- Use the exact path and filename preceded by `-`.
- Ensure that the file was actually loaded before the exclusion stage.

### The list file disappears from the editor

This is intentional. `LOADLIST.S` calls `AbandonFile()` for the list-file buffer after processing it. Save the list before executing the macro.

### The macro is no longer loaded

This is also intentional. At the end of execution, the macro calls `PurgeMacro()` on itself.

## Version history

| README version | Date and time | Changes |
| --- | --- | --- |
| `1.0.0.0.0` | `2026-09-14 22:02:53 UTC` | Initial Markdown documentation for `llist_32.zip` and `LOADLIST.S` version 3.2. Added description, list-file syntax, restrictions, compilation instructions, run instructions, example, and troubleshooting information. |

Future revisions should use sequential version numbers such as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original source information

- Source filename: `LOADLIST.S`
- Macro version: `3.2`
- Target stated by the source: `TSE 2.00`
- Author: Ray Asbury
- Original source date: `1994-09-16 11:04:37`

