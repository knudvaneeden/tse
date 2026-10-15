# SYNCFG2

Version: **1.0.0.0.8**  
Date: 2026-10-15  
Filename/directory support: OpenAI ChatGPT (GPT-6).

Based on the earlier standard SYNCFG2 package, version 1.0.0.0.5, whose
file-to-file conversion was compiled and tested by the user in TSE 4.50.32.
Directory conversion was confirmed working by the user in version 1.0.0.0.6.
This update adds explicit case-insensitive command names. The separate Knud package
has not been changed.

## Compile

Extract all four files into one directory:

- `syncfg2.si`
- `common.h`
- `syncfg.inc`
- `syncfg2_readme.md`

Compile with the SAL compiler belonging to your TSE installation:

```text
sc32b syncfg2.si
```

The output is `syncfg2.mac`. Make sure TSE runs this newly compiled macro.
No compiled macro is included in this package.

## Explicit commands

| Command | Required parameters |
| --- | --- |
| `filetexttobinary` | Input `.txt`/`.ttt` filename, output filename |
| `filebinarytotext` | Input `.syn` filename, output filename |
| `directorytexttobinary` | Input directory of `.txt` files, output directory for `.syn` files |
| `directorybinarytotext` | Input directory of `.syn` files, output directory for `.txt` files |
| `files` | Input filename, output filename (direction from input extension) |
| `directories` | Input directory, output directory |
| `texttobinary` | Text buffer ID, binary buffer ID |
| `binarytotext` | Binary buffer ID, text buffer ID |

All command names are case-insensitive. All file and directory commands
require exactly two paths. An optional leading `-batch` is also
case-insensitive. For example, `FILES`, `Files`, and `files` are equivalent.

`files` rejects directory arguments. `directories` requires both directories
to exist. Explicit directory mode never falls back to file conversion.

## Directional command examples

```text
syncfg2 filetexttobinary "F:\INPUT\cpp.txt" "F:\OUTPUT\cpp.syn"
syncfg2 filebinarytotext "F:\INPUT\cpp.syn" "F:\OUTPUT\cpp.txt"
syncfg2 directorytexttobinary "F:\INPUT" "F:\OUTPUT"
syncfg2 directorybinarytotext "F:\INPUT" "F:\OUTPUT"
```

`filetexttobinary` accepts `.txt` or `.ttt` input. `filebinarytotext` requires
`.syn` input. A mismatched input extension is rejected before conversion.
Explicit file output names are used exactly as supplied. Directory commands
choose the matching `.syn` or `.txt` extension automatically.

## Convert a directory

In TSE's Execute Macro dialog, supply two directory names:

```text
syncfg2 directories "F:\WORDPROC\tse_beta\synhi" "F:\WORDPROC\tse_beta\synhi_output"
```

1. The first parameter is the existing input directory.
2. The second parameter is the existing output directory.

Create the output directory before running the macro. Paths may be quoted,
contain spaces, and have or omit the trailing slash. Relative directories are
resolved once at the start. The entire macro argument string is limited to
255 characters, including spaces and quotes.

For each `.txt` file directly in the input directory, the macro converts the
syntax definition and saves its binary counterpart in the output directory:

| Input | Output |
| --- | --- |
| `cpp.txt` | `cpp.syn` |
| `python.txt` | `python.syn` |
| `sal.txt` | `sal.syn` |

Only immediate `.txt` files are processed. Subdirectories are not scanned.
The `directories` and `directorytexttobinary` commands do not process `.ttt`
inputs. `directorybinarytotext` instead processes `.syn` inputs and writes `.txt`. The input directory
should contain syntax definition files; the macro attempts every `.txt` file.
Basename case is retained. Input and output directories may be the same,
because output files use the distinct `.syn` extension.

Existing output files are replaced using normal TSE save handling. An output
buffer with unsaved edits is skipped and reported as failed. Input files that
are already open are converted from their current editor buffers, including
unsaved edits. Previously open input/output buffers remain open. Buffers opened
only for a successful directory conversion are closed after saving. If saving
fails, the converted output buffer is left open for recovery.

A conversion or save failure is counted and processing continues with the
next file. Original converter error dialogs can still appear. Directory mode
uses the same keyword-wordset questions as file mode; use `-batch` to accept
those automatically and suppress original progress display:

```text
syncfg2 -batch directories "F:\WORDPROC\tse_beta\synhi" "F:\WORDPROC\tse_beta\synhi_output"
```

At the end, a warning displays saved/failed counts, and an unnamed report
buffer lists saved output paths and failed input paths. The report is not
saved automatically. With no matches, the report notes that no `.txt` files
were found or the directory could not be read.

## Existing file-to-file mode

```text
syncfg2 files "F:\WORDPROC\tse_beta\synhi\cpp.txt" "F:\TEMP\cpp.syn"
syncfg2 files "F:\TEMP\cpp.syn" "F:\TEMP\cpp_export.txt"
```

An input `.txt`/`.ttt` file converts to binary; an input `.syn` file converts
to text. The second filename is saved automatically. Use distinct files.

One input filename retains the previous manual-save behavior:

```text
syncfg2 "F:\WORDPROC\tse_beta\synhi\cpp.txt"
```

The old unnamed two-file and two-directory forms remain supported. A single
filename still leaves the converted output unsaved. No arguments retain the
original current-buffer conversion behavior. The
original `texttobinary <text-buffer-id> <binary-buffer-id>` and
`binarytotext <binary-buffer-id> <text-buffer-id>` commands are unchanged.

## Suggested first test

1. Compile `syncfg2.si`.
2. Prepare an input directory containing copies of two valid syntax `.txt` files.
3. Create a separate empty output directory.
4. Run with the two directory parameters.
5. Check that the report shows two saved files and zero failures.
6. Verify that both `.syn` files exist in the output directory.
7. Repeat the operation, then test a directory path containing spaces.
8. Recheck the previously working file-to-file command.

## Validation

All four files are versioned 1.0.0.0.8. Source and include files remain ASCII
with Windows CRLF line endings. Archive integrity and preservation of the
original conversion routines were checked. The new named-command handling has not
yet been compiled or executed in TSE. Directory conversion itself was
confirmed working in version 1.0.0.0.6.

## Changes in 1.0.0.0.7

- Added explicit the file and directory commands commands, each requiring two paths.
- Made all four command names and the leading `-batch` case-insensitive.
- Retained unnamed invocation forms and the original buffer-ID commands.
- Retained the tested directory conversion and original conversion routines.

Test named file and directory commands, uppercase command names, the leading
`-batch` option, and the legacy unnamed forms. Missing or extra paths should
produce an error before conversion starts.

## Changes in 1.0.0.0.8

- Added `filetexttobinary`, `filebinarytotext`, `directorytexttobinary`, and
  `directorybinarytotext`, each accepting exactly two paths.
- Added directory conversion from `.syn` back to `.txt`.
- Retained `files`, `directories`, buffer-ID commands, and unnamed forms.
- Directional command handling and reverse directory mode still require
  compilation and testing in TSE.
