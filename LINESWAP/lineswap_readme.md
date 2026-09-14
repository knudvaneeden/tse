# LINESWAP

## Session

`Create LINESWAP MarkDown Readme`

## README version

`1.0.0.0.0`

## Last updated

`2026-09-14 23:52:34 CEST`

## Description

LINESWAP is a TSE SAL macro that exchanges selected, line-numbered lines in the current buffer with the corresponding lines in another open buffer.

It was written by Truls Thirud on March 12, 1994, under the original name `mSelectAndSwap`, and was placed in the public domain.

The macro is intended for a workflow in which selected lines from a source file are placed in a compact or compressed-view buffer, edited there, and then exchanged with their original lines in the source buffer.

Because LINESWAP performs an exchange instead of a one-way replacement, running it a second time with the same two buffers can undo the previous swap.

## Package contents

| File | Description |
| --- | --- |
| `LINESWAP.S` | TSE SAL source code for the LINESWAP macro. |

After compilation, the SAL compiler normally creates:

| File | Description |
| --- | --- |
| `LINESWAP.MAC` | Compiled macro that can be run by TSE. |

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- At least two open buffers:
  - the current buffer containing the line-numbered lines to exchange;
  - the original or target buffer containing the complete file.
- At least one valid line-number prefix in the current buffer.

The source was originally written for an older TSE release. If it does not compile unchanged with a newer TSE SAL compiler, minor compatibility changes may be required.

## Required line format

LINESWAP recognizes a numbered line when it begins with:

1. zero or more spaces;
2. one or more decimal digits;
3. a colon;
4. one space.

Examples:

```text
  5: First selected line
 18: Another selected line
103: A third selected line
```

The default SAL regular expression is:

```text
 *[0-9]+: 
```

This format is compatible with the line-numbered output expected from TSE's `CompressView` macro.

## How LINESWAP works

For every valid numbered line in the current buffer, LINESWAP:

1. reads the line number at the start of the line;
2. removes the line-number prefix from that line;
3. goes to the same line number in the selected target buffer;
4. places the target buffer's original line into the current buffer, including its line number;
5. places the edited current-buffer line into the target buffer;
6. continues until all recognized numbered lines have been processed.

After processing, the selected target buffer becomes the current buffer.

## Installation

1. Extract `LINESWAP.S` from `lineswap.zip`.
2. Copy `LINESWAP.S` to a suitable TSE macro source directory.
3. Open a command prompt in that directory.
4. Compile the source with the appropriate TSE SAL compiler. For a 32-bit TSE installation, for example:

```bat
sc32 LINESWAP.S
```

5. Confirm that the compiler creates `LINESWAP.MAC` without errors.
6. Put `LINESWAP.MAC` in a directory from which TSE can load or execute macros, or specify its full path when running it.

## Steps to run LINESWAP

1. Open the original file in TSE. This is the target buffer whose lines will be changed.
2. Open or create a second buffer containing the lines you want to exchange.
3. Make sure every exchange line in the second buffer starts with its original line number in the required format, such as ` 25: replacement text`.
4. Edit the text after the line-number prefixes as required.
5. Leave the line-numbered buffer as the current buffer.
6. Run `LINESWAP.MAC` using TSE's normal macro execution command.
7. In the `Swap with` list, select the original target buffer.
8. Press `Enter` to perform the swap.
9. Review the changed target buffer carefully and save it only when the result is correct.

## Important operating notes

- Save or back up important files before running the macro.
- Do not remove or alter the line-number prefixes before running LINESWAP.
- Line numbers must refer to existing lines in the selected target buffer.
- The current buffer cannot be selected as its own target.
- An asterisk in the `Swap with` list identifies an open buffer that has unsaved changes.
- Pressing `Escape` in the buffer-selection list cancels the operation.
- The macro temporarily changes clipboard and kill-buffer settings, then restores them when normal processing finishes.

## Undoing a swap

LINESWAP is reversible because it exchanges the two sets of lines.

To reverse the most recent exchange:

1. Do not change the swapped lines in either buffer.
2. Return to the numbered compact-view buffer.
3. Run `LINESWAP.MAC` again.
4. Select the same target buffer.

The two sets of lines should then be exchanged back to their previous locations. This is separate from TSE's ordinary Undo command and should not replace keeping a backup.

## Messages and error handling

### `Invalid line format: Line numbers missing`

No valid line-number prefix was found in the current buffer.

Check that at least one line starts with digits followed by a colon and a space. A leading group of spaces is allowed.

### `Can't create filelist`

TSE could not create the temporary buffer used for the list of open target buffers.

Close unnecessary files or buffers, check available memory and resources, and try again.

### `0 line(s) changed.`

No valid in-range line was exchanged. Check the line-number format and verify that the referenced lines exist in the selected target buffer.

### Range errors

If a referenced line number is zero or greater than the number of lines in the target buffer, it is not exchanged. By default, LINESWAP prefixes that entry with `?` and reports the number of range errors when processing finishes.

Example:

```text
?9999: This target line does not exist
```

## Configuration

The behavior can be adjusted near the beginning of `LINESWAP.S` before recompiling.

```text
cMarkRangeErrors = 1
cReportCount     = 1
```

- `cMarkRangeErrors = 1` prefixes out-of-range entries with `?`.
- `cMarkRangeErrors = 0` leaves out-of-range entries unmarked.
- `cReportCount = 1` displays the number of changed lines after a successful run without range errors.
- `cReportCount = 0` suppresses that count when no range errors occur.

The recognized line-number format is controlled by:

```text
sLineNumberRegEx[] = " *[0-9]+: "
```

Only change this expression if the compact-view line format is also changed and you understand TSE SAL regular expressions.

## Version history

### 1.0.0.0.0 — 2026-09-14 23:52:34 CEST

- Created `lineswap_readme.md`.
- Documented the macro's purpose, requirements, line format, installation, execution, reversible swap behavior, configuration, and error messages.
- Based the instructions on the supplied `LINESWAP.S` source from `lineswap.zip`.

## Original macro history

### 1.0 — 1994-03-12

- Initial version by Truls Thirud.

## License

The author states in `LINESWAP.S` that the macro is in the public domain.
