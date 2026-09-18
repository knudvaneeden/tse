# LOADLIST

## Version information

- Package version: `1.0.0.0.0`
- Package date: `2026-09-18`
- Package time: `23:05:00 CEST`
- Original source date: `1994-08-30`
- Original author: Ian A. Brown
- Documentation prepared with: OpenAI Codex

## Description

LOADLIST is a TSE SAL command-line extension that loads files from a plain-text list.

The list file contains one filename or filespec per line. LOADLIST recognizes a `-p` command-line option followed immediately by the list filename. It removes that option from TSE's command line, loads every nonblank entry in the list, and leaves all other command-line parameters intact.

For example:

```text
E *.cpp -pfilelist.txt *.h
```

This loads:

- every file matched by `*.cpp`;
- every nonblank filename or filespec in `filelist.txt`;
- every file matched by `*.h`.

LOADLIST passes each list entry to `EditFile()` with the `-a` option. Wildcard entries are therefore loaded directly instead of opening a file-selection list.

If TSE is started without a command line, `mScanCommandLine()` sets the default filename to `untitled`.

## Package contents

| File | Purpose |
| --- | --- |
| `LOADLIST.S` | Original TSE SAL source code. |
| `loadlist.ini` | Initial reference configuration file. |
| `loadlist_readme.md` | Description, help, installation, and usage instructions. |

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- Access to the source used to build the editor startup macro, normally `TSE.S`, or another startup macro from which these procedures can be called.
- A plain-text list containing one filename or filespec per line.

## Important integration note

The supplied source is not a complete standalone macro. It defines these two procedures:

- `mLoadFromList(string sCmdLine)`
- `mScanCommandLine()`

The original author intended both procedures to be incorporated into `TSE.S`. The editor's `WhenLoaded()` procedure must call `mScanCommandLine()` so that the command line is processed when TSE starts.

The supplied `loadlist.ini` is a documented initial configuration template. The original 1994 `LOADLIST.S` does **not** read an INI file, so changing the INI does not change runtime behavior unless INI-reading support is added to the SAL source.

## Installation

1. Make a backup copy of your current `TSE.S` and compiled startup macro.
2. Open `LOADLIST.S` and your `TSE.S` source in TSE.
3. Copy `mLoadFromList()` and `mScanCommandLine()` into `TSE.S`.
4. Locate the `WhenLoaded()` procedure in `TSE.S`.
5. Add this call at an appropriate point in `WhenLoaded()`:

```sal
mScanCommandLine()
```

6. Compile the modified `TSE.S` with the SAL compiler appropriate for your TSE installation.
7. Install the newly compiled macro according to your normal TSE startup procedure.
8. Restart TSE before testing the new command-line option.

## Preparing a list file

Create a plain-text file containing one filename or filespec per line. Blank lines are ignored.

Example `filelist.txt`:

```text
C:\WORK\PROJECT\MAIN.C
C:\WORK\PROJECT\UTIL.C
C:\WORK\PROJECT\INCLUDE\*.H
```

Relative filenames are resolved using TSE's current working directory. Use full paths when the files are located elsewhere or when the current directory is uncertain.

Under a Windows command prompt, a list can be generated with a command such as:

```bat
DIR /B *.c > filelist.txt
```

The original documentation also suggests any other command that writes filenames only, such as a suitable `GREP -l` command.

## Running LOADLIST

### Load files from a list

Start TSE with `-p` immediately followed by the list filename:

```bat
E -pfilelist.txt
```

There must be no space between `-p` and the list filename.

### Use a full path to the list

```bat
E -pC:\TEMP\filelist.txt
```

### Combine the list with ordinary TSE arguments

```bat
E *.cpp -pfilelist.txt *.h
```

LOADLIST removes only its own `-p...` argument. TSE continues to process the remaining arguments.

### Generate the list and start TSE

```bat
DIR /B *.c > filelist.txt
E -pfilelist.txt
```

## Runtime behavior

1. `mScanCommandLine()` reads TSE's `DosCmdLine` setting.
2. If the command line is empty, it sets the command line to `untitled`.
3. Otherwise it calls `mLoadFromList()`.
4. `mLoadFromList()` searches for `-p` or `-P`.
5. It removes the LOADLIST option and list filename from `DosCmdLine`.
6. It opens the list file.
7. It reads each line and ignores blank lines.
8. It calls `EditFile()` for every nonblank entry, using the `-a` option.
9. It closes the list file without saving it.
10. It displays the number of filespecs successfully loaded.

## Help and troubleshooting

### The `-p` option does nothing

Confirm that `mScanCommandLine()` is called by the active `WhenLoaded()` procedure and that the modified startup macro was compiled and installed.

### The list file cannot be found

Use a full path after `-p`, or start TSE in the directory containing the list file.

```bat
E -pC:\TEMP\filelist.txt
```

### A listed file cannot be found

Relative entries are interpreted from TSE's current working directory. Put full paths in the list if necessary.

### A path contains spaces

The original parser treats a space as the end of the `-p` argument. Consequently, a list filename containing spaces is not reliably supported. Prefer a path and filename without spaces.

### The INI settings have no effect

This is expected with the supplied original source. `loadlist.ini` records possible initial values and limitations, but `LOADLIST.S` contains no INI-reading code.

### TSE opens `untitled`

That is the original default behavior when TSE starts with an empty command line. Remove or change the following statement in `mScanCommandLine()` if a different behavior is required:

```sal
Set( DosCmdLine, "untitled" )
```

## Limitations

- The source is intended to be incorporated into a startup macro and is not directly runnable as supplied.
- The command-line buffers and list-entry buffers are limited to 128 characters in the original source.
- A list filename containing spaces is not reliably supported by the original parser.
- The supplied source does not read `loadlist.ini`.
- Each list line is treated as a filename or filespec; comments are not specially recognized.
- The reported count is the number of successful `EditFile()` calls, which can differ from the number of physical files when wildcard filespecs are used.

## Safety recommendation

Back up `TSE.S` and its compiled macro before changing the startup code. Test the integration first with a short list containing disposable or read-only files.

## Version history

### 1.0.0.0.0 - 2026-09-18 23:05:00 CEST

- Added complete Markdown documentation.
- Added installation and execution instructions.
- Added examples and troubleshooting information.
- Added the initial `loadlist.ini` reference file.
- Preserved the original `LOADLIST.S` source without modification.
