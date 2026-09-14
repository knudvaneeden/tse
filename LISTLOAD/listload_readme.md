# LISTLOAD

**README filename:** `listload_readme.md`  
**Session name:** `Create LISTLOAD MarkDown Readme`  
**README version:** `1.0.0.0.0`  
**Date:** 2026-09-14  
**Time:** 19:32:27 UTC  
**Created with:** OpenAI Codex

## Description

LISTLOAD is a macro for The SemWare Editor (TSE) that opens multiple files whose names are stored in an ASCII text file.

The active file must be a plain-text list containing one filename on each line. LISTLOAD reads every line, opens the specified file with `EditFile()`, returns to the list file, and continues with the next entry.

After all entries have been processed, LISTLOAD closes the list file with `AbandonFile()`.

## Package Contents

The package contains:

- `listload.s` - TSE SAL source code.
- `listload.mac` - Compiled macro, if supplied in the package.
- `listload_readme.md` - This documentation.

## Requirements

LISTLOAD requires:

- The SemWare Editor.
- A compatible TSE SAL compiler, such as `sc32.exe`.
- An ASCII text file containing the files that must be opened.
- One filename on each line of the list file.
- No blank lines in the list file.

The original source uses 38-character strings for filenames. Therefore, filenames and paths longer than 38 characters can be truncated and may fail to open.

## How LISTLOAD Works

LISTLOAD performs the following operations:

1. Counts the number of lines in the current list file.
2. Saves the name of the current list file.
3. Moves to the first line.
4. Reads up to 38 characters from that line.
5. Opens the specified file with `EditFile()`.
6. Reopens or returns to the list file.
7. Advances to the next line.
8. Repeats the process until the final line is reached.
9. Closes the list file with `AbandonFile()`.

## Preparing the List File

Create a plain ASCII text file containing one filename on each line.

Example:

```text
file1.txt
file2.txt
example.s
notes.doc
```

Files in the current working directory can be listed without a full path:

```text
first.txt
second.txt
third.txt
```

Files outside the current working directory should be specified with their complete paths:

```text
C:\TSE\MYFILE.S
C:\WORK\NOTES.TXT
D:\SOURCE\PROJECT.S
```

A list can also contain both relative filenames and full paths:

```text
localfile.txt
C:\TSE\MACROS\example.s
D:\DOCUMENTS\notes.txt
```

Do not insert blank lines because the original macro does not skip or validate blank entries.

Do not add comments, descriptions, quotation marks, or other text after a filename. Each line should contain only the filename or path that LISTLOAD must open.

## Compiling LISTLOAD

Open a command prompt in the directory containing `listload.s`.

Compile it with:

```bat
sc32 listload.s
```

A successful compilation should create:

```text
listload.mac
```

If `sc32.exe` is not in the system `PATH`, invoke it using its full path:

```bat
C:\TSE\sc32.exe listload.s
```

Adjust the path to match the location of the TSE SAL compiler on your system.

## Installing the Macro

Copy `listload.mac` to a directory from which TSE can load macros.

Depending on the TSE configuration, this can be:

- The directory containing the TSE editor.
- The configured TSE macro directory.
- The same directory as the list file.
- Another directory included in the TSE macro search path.

The macro can also be loaded manually from inside TSE before it is executed.

## Running LISTLOAD from TSE

Use the following procedure:

1. Start The SemWare Editor.
2. Open the ASCII text file containing the filenames.
3. Make sure this list file is the current file.
4. Save the list file before running LISTLOAD.
5. Load `listload.mac` if it has not already been loaded.
6. Execute the LISTLOAD macro.
7. LISTLOAD opens every file named in the list.
8. When processing is complete, LISTLOAD closes the original list file.

The list file must remain the current file when the macro starts because LISTLOAD uses `CurrFileName()` and `NumLines()` on the active file.

## Running LISTLOAD from the Command Line

The original source documents the following syntax:

```text
E [LISTFILE name] -ELISTLOAD.MAC
```

For example:

```bat
e files.lst -elistload.mac
```

Depending on the TSE installation and executable name, the command might instead resemble:

```bat
g32 files.lst -elistload.mac
```

or:

```bat
e32 files.lst -elistload.mac
```

Replace `files.lst` with the name of the ASCII list file.

Replace the editor executable with the correct executable for the installed TSE version.

## Example

Create a file named `files.lst`:

```text
C:\WORK\FIRST.TXT
C:\WORK\SECOND.TXT
C:\WORK\THIRD.TXT
```

Run:

```bat
g32 files.lst -elistload.mac
```

LISTLOAD should open:

1. `C:\WORK\FIRST.TXT`
2. `C:\WORK\SECOND.TXT`
3. `C:\WORK\THIRD.TXT`

After the last file has been opened, `files.lst` is closed.

## Important Warnings

### The List File Is Closed Automatically

At the end of the macro, LISTLOAD executes:

```sal
AbandonFile()
```

This closes the list file.

Save the list file before executing LISTLOAD. Unsaved modifications to the list file could be discarded when it is abandoned.

### Blank Lines Are Not Supported

The original source assumes that the list contains no blank lines.

A blank line causes LISTLOAD to pass an empty filename to `EditFile()`. The result depends on the behavior of the installed TSE version.

### Filename Length Is Limited

The source declares:

```sal
string sfilename[38],cnxtfile[38]
```

It also reads each filename with:

```sal
cnxtfile = GetText(1,38)
```

Consequently, only the first 38 characters of each filename or path are read. Longer paths can be truncated.

### One Filename Per Line

Each line must contain exactly one filename or path. Do not place multiple filenames on one line.

### No Automatic Error Checking

The original macro does not verify whether:

- A list entry is blank.
- A file exists.
- A directory exists.
- A filename is valid.
- `EditFile()` succeeds.
- A line contains trailing spaces.
- A path exceeds 38 characters.

Review the list file carefully before running the macro.

### Current Directory

A filename without a complete path is resolved according to the current working directory used by TSE.

If LISTLOAD cannot find a relative filename, use the complete path in the list file.

## Troubleshooting

### A File Does Not Open

Check that:

- The filename is spelled correctly.
- The file exists.
- The full path is correct.
- The path does not exceed 38 characters.
- The line contains no leading or trailing spaces.
- The line contains no quotation marks.
- The file is accessible to TSE.

### LISTLOAD Attempts to Open an Empty Filename

Remove all blank lines from the list file.

Also check that the final line does not contain unwanted whitespace.

### A Long Path Is Truncated

The original source reads only 38 characters from every line.

Shorten the path, move the files to a directory with a shorter path, or modify the source to use longer strings and read more characters.

### The Wrong File Is Processed as the List

Make sure the intended list file is the current TSE file before executing LISTLOAD.

### The Macro Cannot Be Found

Check that:

- `listload.mac` was compiled successfully.
- The macro is in the TSE macro directory.
- The macro directory is part of the TSE macro search path.
- The command uses the correct macro filename.
- TSE can access the directory containing the macro.

### The List File Disappears After Processing

This is expected behavior. LISTLOAD closes the list file with `AbandonFile()` after it reaches the last line.

The files listed inside it should remain open.

## Source-Code Overview

The main procedure begins with:

```sal
proc MAIN()
```

The following variables are used:

- `cline` - Current line number in the list file.
- `totline` - Total number of lines in the list file.
- `sfilename` - Name of the active list file.
- `cnxtfile` - Filename read from the current line.

The number of entries is obtained with:

```sal
totline = NumLines()
```

The current list filename is saved with:

```sal
sfilename = CurrFileName()
```

Each list entry is read with:

```sal
cnxtfile = GetText(1,38)
```

The listed file is opened with:

```sal
EditFile(cnxtfile)
```

LISTLOAD then returns to the list file with:

```sal
EditFile(sfilename)
```

After processing every line, the list file is closed with:

```sal
AbandonFile()
```

## Limitations

The original LISTLOAD implementation has the following limitations:

- Filenames and paths are limited to 38 characters.
- Blank lines are not ignored.
- Comments are not supported in the list file.
- Leading and trailing spaces are not removed.
- Quoted filenames are not specially processed.
- Missing files are not reported by the macro itself.
- Failed `EditFile()` calls are not handled.
- The list file is automatically abandoned after processing.
- The macro assumes that the active file is a valid list file.

## Suggested Safe Usage

Before running LISTLOAD:

1. Back up important work.
2. Save the list file.
3. Save all other modified files.
4. Verify that every list entry is valid.
5. Remove all blank lines.
6. Check that every path contains no more than 38 characters.
7. Make sure the intended list is the current TSE file.
8. Run LISTLOAD.
9. Verify that all expected files were opened.

## Version History

### Version 1.0.0.0.0 - 2026-09-14 19:32:27 UTC

- Created `listload_readme.md`.
- Added a description of LISTLOAD.
- Added package requirements.
- Added list-file preparation instructions.
- Added compilation and installation instructions.
- Added steps for running LISTLOAD from TSE.
- Added command-line execution examples.
- Documented the 38-character filename limitation.
- Documented the prohibition on blank lines.
- Documented automatic closing of the list file.
- Added troubleshooting information.
- Added safe-usage recommendations.
- Added a source-code overview.

Future README revisions should increment the final version component:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## Session Information

```text
Session name: Create LISTLOAD MarkDown Readme
README filename: listload_readme.md
README version: 1.0.0.0.0
Date: 2026-09-14
Time: 19:32:27 UTC
Created with: OpenAI Codex
```
