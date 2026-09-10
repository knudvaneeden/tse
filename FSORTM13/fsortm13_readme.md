# FSORTM13 - mSort v1.3 for The SemWare Editor

## Document information

- README version: 1.0.0.0.4
- Previous version: 1.0.0.0.3
- Date: 2026-09-10
- Time: 00:45:51 UTC
- Source package: `fsortm13.zip`
- Macro source: `MSORT.S`
- Original macro version: 1.3 (1993-07-14)
- Original authors: Terry Harris, with extensions by Mel Hulse
- Created with: OpenAI Codex (GPT-5)

## Version history

### 1.0.0.0.4 - 2026-09-10 00:56:00 UTC

- Added the required duration argument to both `Sound()` calls for compatibility with the current TSE SAL compiler.
- The completion tones now use `Sound(5000, 1)` and `Sound(4000, 1)`.

### 1.0.0.0.3 - 2026-09-10 00:53:47 UTC

- Replaced the obsolete Win32-incompatible `Query(SwapPath)` calls.
- Temporary files now use the `TEMP` directory, then `TMP`, and finally the current directory when neither environment variable is defined.
- Quoted temporary filenames so Windows paths containing spaces are supported.
- Cleanup now deletes only the two temporary files created by this macro.

### 1.0.0.0.2 - 2026-09-10 00:49:42 UTC

- Made `MSORT.S` self-contained so it can be compiled directly with `sc32 msort.s`.
- Added the previously assumed `sort_flags` variable and the `OnOffStr()`, `ShowSortFlag()`, and `ToggleSortFlag()` helpers.
- Added `Main()` so running the compiled macro opens the Sort Options menu.

### 1.0.0.0.1 - 2026-09-10 00:45:51 UTC

- Expanded the documentation with setup, operating instructions, menu options, requirements, behavior, and troubleshooting information.
- Clarified the difference between the internal TSE sort and the external `FSORT` program.

### 1.0.0.0.0 - 2026-09-10 00:45:51 UTC

- Initial Markdown documentation for the FSORTM13 package.

## Description

FSORTM13 contains the TSE SAL macro `mSort` version 1.3. It extends the normal sorting facilities of The SemWare Editor (TSE) by integrating TSE's internal sort with the external `FSORT` program.

For a marked block containing fewer than 1,000 lines, the macro selects TSE's internal sort by default. For 1,000 lines or more, it selects the external sort by default. The user can override this choice from the Sort Options menu.

The macro supports:

- Ascending and descending sorting.
- Case-sensitive and case-insensitive sorting.
- Automatic selection of internal or external sorting based on block size.
- Manual selection of the internal or external sorter.
- Column-block sorting using the marked column's starting position and width.
- Sorting line and stream blocks by the first 80 columns of each line.
- Decimal-number sorting through the external sorter.
- Removal of lines with duplicate sort keys through the external sorter.
- Preservation of the cursor position and marked block after an external sort.

## Package contents

- `MSORT.S` - TSE SAL source code for the `mSort` procedure.
- `FILE_ID.DIZ` - Original short package description.

The external `FSORT` executable is not included in this archive. The original source comments refer to the separately distributed `FSORT10.ZIP` package.

## Requirements

- The SemWare Editor with a SAL compiler compatible with this source.
- The external `FSORT` program if external sorting, decimal sorting, or duplicate-key removal is required.
- `FSORT` must be accessible through the system `PATH`.
- Access to the TSE configuration source, traditionally `TSE.S` and `TSE.KEYS`, because `MSORT.S` is designed to be included in the main TSE configuration.

## Installation and configuration

### Standalone installation

1. Copy `MSORT.S` to the desired macro source directory.
2. Open a command prompt in that directory.
3. Compile the macro:

   ```bat
   sc32 msort.s
   ```

4. Install the resulting compiled macro using the normal TSE macro installation method.
5. Mark a block in TSE and run `msort`. The Sort Options menu opens automatically.

### Integration into TSE.S

1. Install the external `FSORT` program in a directory listed in the system `PATH`.
2. Read the documentation supplied with `FSORT` so that its command-line behavior and limitations are understood.
3. Copy `MSORT.S` to the directory containing the TSE configuration source files.
4. Add the following include directive to `TSE.S` immediately before the include for `TSE.KEYS`:

   ```sal
   #include "MSORT.S"
   ```

5. The updated standalone source declares `sort_flags` and its menu helpers itself. If `TSE.S` already defines identically named symbols, keep only one set of definitions to prevent duplicate-symbol errors.
6. Add this forward declaration after the global declarations:

   ```sal
   FORWARD PROC mSort(Integer M)
   ```

7. To make the main Utility menu's Sort command run `mSort` directly, replace its call to:

   ```sal
   Sort(sort_flags)
   ```

   with:

   ```sal
   mSort(Off)
   ```

8. Optionally bind `mSort(On)` to a key in `TSE.KEYS`. Calling it with `On` displays the Sort Options menu before sorting.
9. Recompile the main TSE configuration macro and load or burn it into TSE according to the normal TSE configuration procedure.

The exact include syntax and configuration-file layout can vary between TSE releases. Preserve the conventions already used by the installed TSE configuration.

## How to run FSORTM13

1. Open the file to be sorted in TSE.
2. Mark the text that must be sorted. A line, stream, or column block can be used.
3. Choose one of the configured ways to start the macro:

   - Select the modified **Sort** command from TSE's Utility menu to execute `mSort(Off)` with the existing TSE sort settings.
   - Press the key assigned to `mSort(On)` to open the Sort Options menu.

4. If the Sort Options menu is displayed, adjust the desired settings.
5. Select **Sort** to perform the operation, or **Quit** to cancel it.
6. Wait for the completion tones and the `Done...` message.

## Sort Options menu

- **Sort** - Executes the sort with the currently selected options.
- **Quit** - Cancels the operation without sorting.
- **Sort Order** - Toggles between ascending and descending order.
- **Case-Sensitive Sort** - Toggles case-sensitive comparison.
- **External Sort** - Forces or disables use of the external `FSORT` program, except when another selected option requires it.
- **Kill Dup Lines** - Removes lines having duplicate sort keys. This automatically forces external sorting.
- **Decimal** - Sorts signed decimal values, including values containing `+`, `-`, `.`, or scientific notation. This automatically forces external sorting.

Decimal sorting and duplicate-key removal are not supported by TSE's internal sorter. If either option is selected, the macro keeps external sorting enabled.

## How the sort field is selected

- For a marked column block, the starting column and width of that block form the sort key.
- For a marked line or stream block, columns 1 through 80 form the sort key.
- The sort applies only to the marked block in the current file.

## Internal and external sort selection

The default is based on the size of the marked block:

- Fewer than 1,000 lines: internal TSE sort.
- 1,000 lines or more: external `FSORT` sort.

When external sorting is used, the macro writes the marked block to a temporary file in TSE's swap directory, runs `FSORT`, replaces the original marked block with the sorted output, and deletes the temporary files.

## Help and troubleshooting

### `Block must be marked...`

No block is marked in the current file. Mark the lines, stream, or columns that must be sorted and run the command again.

### `Could not run external sort program`

TSE could not start `FSORT`. Confirm that the correct `FSORT` executable is installed and that its directory is included in the system `PATH` visible to TSE.

### `Could not write block`

The macro could not create its temporary input file. Check that TSE's swap directory exists and is writable and that sufficient disk space is available.

### `Could not read sorted block`

The sorted temporary output could not be inserted into the file. Check the swap directory, file permissions, available disk space, and whether `FSORT` successfully produced its output file.

### `Decimal and kill duplicate parms not supported.`

An option requiring `FSORT` was selected while internal sorting was active. Enable **External Sort** and try again.

### Sorting produces an unexpected order

Check the ascending/descending and case-sensitive settings. For a column block, verify that the marked columns contain the intended key. For other block types, remember that only the first 80 columns are used as the key.

## Important notes

- Save or back up important files before testing an older sorting macro on current data.
- The source was written for the TSE configuration structure and SAL language available in 1993. A modern TSE SAL compiler may require compatibility changes.
- The Sort Options menu text inside `MSORT.S` identifies itself as version 1.2 even though the source header and package identify the macro as version 1.3.
- External sorting invokes a DOS command and uses temporary files in TSE's configured swap directory.
- The original package name is FSORTM13, while the required external sorting program is referenced as FSORT/FSORT10.

## License and attribution

No explicit license is included in the archive. Retain the original author information and source comments when redistributing or modifying the macro, and obtain permission where required.
