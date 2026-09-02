# CallList 4.1 for TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-02 19:15:33 CEST (UTC+02:00)  
**Original program version:** 4.1 for The SemWare Editor 2.00  
**Original program date:** 1994-09-26 19:00:33  
**Original author:** E. Ray Asbury, Jr.

## Description

CallList is a legacy source-analysis macro for The SemWare Editor (TSE). It analyzes the source file currently open in the editor and produces a call listing that can help application developers inspect and optimize SAL or C programs.

For SAL source files, the report can show:

- Each procedure and menu definition.
- Commands and procedures called by each block.
- The number of occurrences of each call.
- Call arguments when the complete call text fits the supported width.
- Overall call totals for the complete source file.
- Optional code and stack sizes obtained from a SAL compiler `.MAP` file.

For C source files, CallList creates a simpler function-call report. Calls are divided into ANSI C and non-ANSI categories and include source line numbers. C reports do not use map files and do not provide the same per-function grouping or occurrence totals as SAL reports.

CallList works on a temporary copy of the current source file. The original source file is not modified.

## Files in `clist_41.zip`

| File | Purpose |
| --- | --- |
| `CLIST.DOC` | Original documentation and usage notes. |
| `CLIST.S` | Configurable SAL source for the main CallList launcher. |
| `CLIST.MAC` | Compiled main CallList macro. |
| `CLIST2.MAC` | Compiled analyzer used for C-family source files. |
| `CLIST3.MAC` | Compiled analyzer used for SAL source files. |

Keep the three `.MAC` files together and accessible through TSE's macro search path.

## Supported source files

The supplied `CLIST.S` routes these extensions as follows:

- C analyzer (`CLIST2.MAC`): `.c`, `.cpp`, `.h`, and `.pc`
- SAL analyzer (`CLIST3.MAC`): `.s` and `.ui`

The extension lists can be changed in `CLIST.S`; recompile `CLIST.S` afterward.

## Installation

1. Extract `clist_41.zip`.
2. Copy `CLIST.MAC`, `CLIST2.MAC`, and `CLIST3.MAC` to one of these locations:
   - The current working directory.
   - A directory included in `TSEPath`.
   - The TSE startup directory.
3. Optionally copy `CLIST.S` and `CLIST.DOC` to a source or documentation directory for reference.
4. If you change the settings in `CLIST.S`, compile it with the SAL compiler to create an updated `CLIST.MAC`.

Example compilation command:

```bat
sc32 clist.s
```

The exact compiler name or command may differ with the installed TSE version.

## Configuration

The `Main()` procedure in `CLIST.S` contains the configurable settings.

### Word set

`giCL_WordSet` defines which characters CallList recognizes as parts of words and identifiers. It should contain at least digits and upper- and lowercase letters. If procedure names use extra characters, add those characters to the word set and recompile `CLIST.S`.

The string is limited to 255 characters in the original program.

### Map-file mode

`giCL_UseMapFile` controls SAL map-file processing:

| Value | Behavior |
| --- | --- |
| `0` | Do not use a map file. |
| `1` | Automatically try to use a map file. |
| `2` | Ask each time CallList runs. This is the supplied default. |

To create a SAL map file, compile the analyzed SAL source with the compiler's `-m` option. CallList first looks for a `.MAP` file with the same base name and directory as the current source file. If it cannot find one there, it uses the configured alternate location or prompts for a file, depending on the situation.

Example:

```bat
sc32 -m example.s
```

### Alternate map-file location

`giCL_MapFileAltLoc` specifies another directory in which CallList may search for map files. The supplied value is `C:\`. Change it to a suitable directory if required, then recompile `CLIST.S`.

### Sorting

`giCL_SortSensitive` controls whether generated listings are sorted case-sensitively:

- `koCL_DONT_IGNORE_CASE`: case-sensitive sorting; supplied default.
- `koCL_IGNORE_CASE`: case-insensitive sorting.

## How to run CallList

1. Start TSE.
2. Open the SAL or C source file that you want to analyze.
3. Make sure that source file is the current editor file.
4. Execute the `CLIST` macro using TSE's normal macro execution command.
5. If map-file mode is set to `2` for a SAL file, answer whether CallList should use map data.
6. If requested, select the applicable `.MAP` file.
7. Wait while CallList processes the temporary copy. Progress messages are displayed; large source files may require several minutes.
8. Review the listing produced by CallList.

The main macro selects `CLIST2` for a recognized C-family extension and `CLIST3` for a recognized SAL extension. Files with other extensions are not analyzed unless their extensions are added to `CLIST.S` and the macro is recompiled.

## SAL report interpretation

Within each procedure or menu, `Count` shows how many times a command or procedure call was detected. The totals section combines calls from all analyzed blocks.

When map data is enabled and available:

- `Code` is the compiled code size reported in the map file.
- `Stack` is the reported stack requirement.

These figures can reveal that a small procedure indirectly depends on larger called procedures. They are diagnostic values, not a complete calculation of every transitive dependency.

## Known limitation

CallList removes block comments while parsing. If the literal delimiters `/*` and `*/` appear inside quoted strings used by executable code, the parser may incorrectly treat everything between them as a comment and omit real calls from the report.

The original documentation recommends placing such delimiter strings in named string variables instead of using the literal delimiters directly in command calls.

CallList is a 1994 utility compiled for TSE 2.00. Compatibility with modern TSE releases is not guaranteed; recompilation or source changes may be necessary.

## Troubleshooting

### Nothing happens for the current file

- Confirm that the current file has one of the configured extensions.
- Confirm that all three compiled macros are accessible to TSE.
- Check that `CLIST2.MAC` and `CLIST3.MAC` were not separated from `CLIST.MAC`.

### Calls are missing or identifiers are split incorrectly

- Check the `giCL_WordSet` definition in `CLIST.S`.
- Add every nonstandard character used in identifiers.
- Recompile `CLIST.S` and retry.
- Check whether literal block-comment delimiters occur inside strings.

### Code and stack sizes are absent

- Map information is supported only for SAL analysis.
- Compile the SAL source with the `-m` option.
- Confirm that map-file use is enabled or answer **Yes** when prompted.
- Confirm that the `.MAP` filename matches the source filename or select it when asked.

### The main macro loads, but analysis fails

- Confirm that `CLIST2.MAC` and `CLIST3.MAC` are compatible with `CLIST.MAC` version 4.1.
- Put all three macros in the same searchable directory.
- Bear in mind that these compiled macros target a historical TSE release.

## Version history for this README

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 19:15:33 CEST (UTC+02:00) | Initial Markdown description, installation, configuration, operation, limitations, and troubleshooting guide based on the supplied CallList 4.1 archive. |

Future README updates can increment the final component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Copyright notice

The original files state: Copyright 1994 E. Ray Asbury, Jr. All rights reserved. This README is supplementary documentation and does not change the ownership or licensing of the original software.
