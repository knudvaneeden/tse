# FSORT 1.0

**README version:** 1.0.0.0.0  
**Date:** 2026-09-10  
**Time:** 00:40:05 UTC  
**Original program:** FSORT version 1.0, April 1993  
**Author:** Mike Albert

## Description

FSORT is an MS-DOS command-line utility that reads an ASCII text file, sorts its lines, and writes the sorted data to another file or to the screen. It supports one or more character or numeric sort keys, ascending and descending order, case-insensitive comparisons, and removal of records with duplicate keys.

FSORT preserves the original order of lines whose keys compare as equal. It can sort files larger than available memory by creating temporary work files.

## Package contents

- `FSORT.EXE` - the executable program.
- `FSORT.DOC` - the complete FSORT documentation, including command syntax, operational details, error messages, licensing, and revision history.
- `README.DOC` - the original author's shareware information and program catalogue.

## System requirements

- An IBM-compatible computer or compatible DOS environment.
- MS-DOS 3.00 or later.
- Approximately 150 KB or more of free conventional memory. More available memory can improve performance.
- Input stored as an MS-DOS ASCII text file.
- Sufficient free disk space for the output file and any temporary work files.

On a modern 64-bit version of Windows, `FSORT.EXE` may not run directly because it is a 16-bit DOS program. Use DOSBox, DOSBox-X, a DOS virtual machine, or a similar DOS-compatible environment.

## Installation

1. Extract all files from `fsort10.zip` into one directory.
2. Open an MS-DOS command prompt or start a DOS-compatible environment.
3. Change to the directory containing `FSORT.EXE`.
4. Optionally add that directory to the DOS `PATH` so that `FSORT` can be started from other directories.
5. Keep `FSORT.DOC` available as the complete original reference.

## How to run FSORT

To display FSORT's built-in introductory help, run:

```dos
FSORT
```

The general command syntax is:

```dos
FSORT [options] [<] input_file [>] output_file
```

The arguments can be entered in any order. The first filename is the input file and the second filename is the output file. If no output file is supplied, FSORT writes the result to the screen. Standard DOS input/output redirection and pipes are supported. Wildcards (`*` and `?`) are not supported in filenames.

## Options

| Option | Meaning |
|---|---|
| `/+n` | Sort ascending by the key beginning in column `n`. |
| `/-n` | Sort descending by the key beginning in column `n`. |
| `/+n:m` | Sort ascending by a key beginning in column `n` and having length `m`. |
| `/-n:m` | Sort descending by a key beginning in column `n` and having length `m`. |
| `/+Nn` | Sort ascending by a decimal numeric key beginning in column `n`. |
| `/-Nn` | Sort descending by a decimal numeric key beginning in column `n`. |
| `/+Nn:m` | Sort ascending by a numeric key beginning in column `n` and having length `m`. |
| `/-Nn:m` | Sort descending by a numeric key beginning in column `n` and having length `m`. |
| `/C` | Ignore differences between uppercase and lowercase letters. |
| `/U` | Discard lines whose sort keys duplicate an earlier key. |
| `/T` | Display trace and status information during the sort. |

Column numbers begin at 1. When a key length is omitted, the key extends to the end of the line or to the beginning of another defined key, whichever comes first.

## Examples

Sort complete lines in ascending ASCII order:

```dos
FSORT TEST.IN TEST.OUT
```

Sort by the text beginning in column 5:

```dos
FSORT /+5 INPUT.TXT OUTPUT.TXT
```

Sort the output of `DIR` numerically by the ten-character field beginning in column 13:

```dos
DIR | FSORT /+N13:10
```

Sort first by columns 5 through 9 in descending order and then by the numeric value in columns 10 through 14 in ascending order, ignoring letter case:

```dos
FSORT /-5:5 /+N10:5 /C DATA.IN DATA.OUT
```

Sort a file in place and remove duplicate records while ignoring letter case:

```dos
FSORT /C /U DATA.TXT DATA.TXT
```

Back up the file before performing an in-place sort. Do not use DOS redirection with identical input and output filenames because DOS can truncate or destroy the input before FSORT reads it.

## Using multiple sort keys

Specify multiple key options in priority order. FSORT compares the first key; if two keys are equal, it compares the second key, followed by each additional key until a difference is found or all keys have been checked.

Sort keys must not overlap or begin in the same column. Character keys are compared in ASCII order, and control characters such as tabs are not expanded before comparison.

## Numeric keys

A numeric key can contain leading spaces or tabs, an optional `+` or `-` sign, a decimal point, and scientific notation such as `5.9E-5`. Numeric parsing stops at the first character that cannot be part of the number.

## Temporary work files

FSORT can create temporary files while sorting large inputs. Use the `FSTEMP` environment variable to select one or more temporary directories, separated by semicolons:

```dos
SET FSTEMP=E:\TEMP;D:\
```

FSORT tries `FSTEMP` first, followed by `TEMP` and `TMP`. If none is available, it may use the root directories of available hard or network drives. Ensure every configured directory exists, is writable, and has enough free space.

## Interrupting FSORT

Press `Ctrl+C` or `Ctrl+Break` to stop the program. FSORT reports that the user aborted the operation and attempts to remove its work files and partially written output file.

## Troubleshooting

- If FSORT cannot open the input file, verify its name, path, and access permissions.
- If it cannot create a work or output file, check the `FSTEMP`, `TEMP`, and `TMP` paths, permissions, and available disk space.
- If FSORT reports insufficient memory, close other DOS programs or TSRs and provide more conventional memory.
- If it cannot open enough files, close programs that consume file handles or increase the DOS `FILES` setting in `CONFIG.SYS`.
- If a key is rejected, confirm that the column and length are positive, do not exceed the supported line width, and do not overlap another key.
- Run `FSORT /T ...` to display status information that can help diagnose a failure.
- Run `FSORT ?` to list the arguments recognized by the program.

## Performance tips

- Place temporary files on the fastest available disk or a sufficiently large RAM disk.
- Make as much conventional memory as possible available to FSORT.
- Use as few sort keys as necessary.
- Avoid numeric keys and `/C` when they are not required.
- Make enough DOS file handles available when sorting large files.

## Important notes

- FSORT is intended for ASCII text files in DOS format, not arbitrary binary files.
- The `/U` option compares the defined keys, not necessarily the entire lines. With ordinary character keys, trailing spaces can make otherwise similar keys different.
- Lines without a usable key are removed when `/U` is active.
- The program and its original documentation are historical shareware from 1993. Read `FSORT.DOC` for the original licensing and warranty terms.

## Version history

### 1.0.0.0.0 - 2026-09-10 00:40:05 UTC

- Created `fsort10_readme.md`.
- Added a description of FSORT and the package contents.
- Added system requirements, installation instructions, command syntax, options, examples, temporary-file configuration, troubleshooting, safety notes, and performance guidance.
- Documented compatibility considerations for modern 64-bit Windows systems.

Future README revisions should increment the final version component in sequence: `1.0.0.0.1`, `1.0.0.0.2`, and so on.
