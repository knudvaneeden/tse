# FSORTM14

Version: 1.0.0.0.2  
Date: 2026-09-10  
Time: 03:13:27 CEST (01:13:27 UTC)

## Description

FSORTM14 is a stand-alone TSE SAL sorting macro based on the historical MSORT 1.4 utility by Terry Harris, Mel Hulse, and Joseph Baechtel. It sorts a marked block with either TSE's internal sort or the external `FSORT.EXE` program.

The macro automatically recommends the internal sort for blocks below 1,000 lines and the external sort for larger blocks. A column block defines the sort field from its starting column and width. Other block types use columns 1 through 80 by default.

FSORTM14 supports:

- Ascending or descending sorting.
- Case-sensitive or case-insensitive sorting.
- Internal or external sorting.
- Decimal values containing `+`, `-`, `.`, or scientific notation.
- Removal of lines with duplicate sort keys.
- As many as ten independently configured sort keys.
- Character or decimal sorting for each key.
- Direct column entry or point-and-shoot selection of key columns.

Decimal sorting, duplicate removal, and multiple keys require `FSORT.EXE`.

## Stand-alone changes

The supplied `msort.s` no longer has to be included in `TSE.S`:

- Added its own `Main()` procedure.
- Added a local `sort_flags` variable.
- Added local `ShowSortFlag()`, `ToggleSortFlag()`, and `OnOffStr()` helpers formerly supplied by `TSE.S`.
- Replaced the obsolete `Query(SwapPath)` use with the Windows `TEMP` or `TMP` directory, with the current directory as a fallback.
- Updated both `Sound()` calls to include the required second parameter.
- Removed `Query(MacPath)`, which is not a valid configuration query in current TSE. `FSORT.EXE` is now resolved through Windows `PATH`.

## Requirements

- The SemWare Editor (TSE), 32-bit edition.
- The TSE SAL compiler `SC32.EXE`.
- `FSORT.EXE` for external sorting and all advanced options.

Place `FSORT.EXE` in a directory on the Windows `PATH`.

## Compile

1. Extract the package to a directory of your choice.
2. Open a command prompt in that directory.
3. Compile the source:

   ```text
   sc32 msort.s
   ```

4. Confirm that the compiler creates `msort.mac` without errors.

No changes to `TSE.S` or `TSE.KEYS` are required.

## Run

1. Open the file that contains the lines to sort.
2. Mark a line, stream, or column block.
3. Run `msort.mac` from TSE's macro command or macro execution facility.
4. Review the Sort Options menu.
5. Choose the sort order, case handling, and internal/external mode.
6. Optionally enable multiple keys, duplicate removal, or decimal sorting.
7. Select **Sort** to start or **Quit** to cancel.

The macro leaves the sorted block marked and attempts to restore the original cursor position.

## Multiple sort keys

1. Enable **Specify Multiple Sort Keys** in the Sort Options menu.
2. At each prompt, enter the starting and ending columns.
3. Choose ascending character, descending character, ascending decimal, or descending decimal.
4. Repeat for as many keys as required, up to ten.
5. Press `Shift+F3` when the key definitions are complete.

To use point-and-shoot selection, press `Enter` without typing the first starting column. Move the cursor to the start and end of each key and press `Enter` at each position. Press `Esc` to cancel.

## Troubleshooting

### Block must be marked

Mark the text to sort before running the macro.

### Could not run external sort program

Verify that `FSORT.EXE` exists in a directory on the Windows `PATH`.

### Could not write or read the sorted block

Check that the Windows `TEMP` or `TMP` directory exists and is writable. If neither variable exists, the macro uses the current directory.

### Internal sort does not accept an option

Decimal mode, duplicate removal, and multiple sort keys require the external sorter. Enable **External Sort** and ensure `FSORT.EXE` is available.

## Files

- `msort.s` - stand-alone TSE SAL source.
- `fsortm14_readme.md` - description, help, and operating instructions.

## Version history

- 1.0.0.0.0 - Initial README for the original FSORTM14/MSORT 1.4 source.
- 1.0.0.0.1 - Converted `msort.s` into a stand-alone macro and applied current TSE SAL compatibility fixes.
- 1.0.0.0.2 - Removed invalid `Query(MacPath)` calls that caused compiler error 2336.

## Original program information

- Original utility: MSORT 1.4
- Original release date: 1993-09-13
- Original authors: Terry Harris and Mel Hulse
- Multiple-key enhancements: Joseph Baechtel
- Stand-alone adaptation: OpenAI GPT-5.6
