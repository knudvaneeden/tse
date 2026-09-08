# FillNum2

**README version:** 1.0.0.0.0  
**Created:** 2026-09-08 15:45:38 UTC  
**Package:** `fillnum2.zip`  
**Macro source:** `fillnum.s`  
**Original author:** SemWare  
**Environment:** The SemWare Editor (TSE), SAL macro language

## Description

FillNum2 is a TSE SAL macro that fills a marked **column block** with a sequence of numbers. The sequence can increase or decrease and can optionally stop at a specified value.

The macro provides a menu in which you can configure:

- The first number in the sequence.
- An optional final number.
- A positive or negative step value.
- The numeric base used to display the numbers.
- A one-character field-padding character.

The numbers are written into the selected column block using overwrite mode. Their formatted width is determined by the width of the marked column block.

## Package contents

| File | Description |
|---|---|
| `fillnum.s` | TSE SAL source code for the Numeric FillBlock macro. |

## Requirements

- The SemWare Editor (TSE).
- A TSE version compatible with the supplied SAL source.
- The TSE SAL compiler if `fillnum.s` has not yet been compiled.

No external DLLs or other support files are included or required.

## Installation

1. Extract `fillnum2.zip` to a directory of your choice.
2. Copy `fillnum.s` to your preferred TSE macro source directory, or leave it in the extracted directory.
3. Compile the source with the TSE SAL compiler. For example:

   ```text
   sc32 fillnum.s
   ```

4. Make the compiled macro available to TSE according to your normal macro installation procedure.

The exact output filename and installation location can depend on the TSE version and configuration.

## How to run

1. Open a file in TSE.
2. Mark a **column block** covering the lines and columns that must receive the numbers.
3. Run the compiled `fillnum` macro. The original source suggests selecting it from TSE's **Potpourri** menu. You may also run it through your usual TSE macro command or assign it to a key.
4. Configure the fields in the **Numeric FillBlock** menu.
5. Select **Fill Block**.

The macro returns the cursor and block state to their prior positions after filling the block.

## Menu options

| Option | Default | Meaning |
|---|---:|---|
| **From** | `1` | First number written into the block. |
| **To** | `0` | Optional stopping value. A value of `0` disables this stopping test, so filling continues through the block or to the end of the file. |
| **Step** | `1` | Amount added after each number. Use a positive value to count upward or a negative value to count downward. |
| **Base** | `10` | Numeric base used when formatting the numbers. |
| **Fill char** | Space | One character used to pad values to the width of the column block. |
| **Fill Block** | — | Starts the fill operation using the current settings. |

## Examples

### Increasing sequence

To insert `1`, `2`, `3`, and so on:

```text
From:      1
To:        0
Step:      1
Base:     10
Fill char: <space>
```

### Decreasing sequence

To insert `10`, `8`, `6`, `4`, and `2`:

```text
From:     10
To:        2
Step:     -2
Base:     10
Fill char: <space>
```

### Zero-padded sequence

Mark a column block four characters wide and set the fill character to `0`. With a starting value of `1`, the output is formatted as values such as:

```text
0001
0002
0003
```

## Important notes

- A column block must be marked in the current file. Otherwise, the macro displays `Column block must be marked` and makes no changes.
- Existing text inside the selected columns is overwritten.
- The marked block must be wide enough for the formatted values you intend to insert.
- Use a positive step when the final value is greater than the starting value.
- Use a negative step when the final value is less than the starting value.
- The macro stops when it passes the configured final value, reaches the end of the marked block, or reaches the end of the file.
- The source has no built-in key assignment.

## Help and troubleshooting

### The macro reports that a column block must be marked

The selected block is not a TSE column block, or no block is active in the current file. Mark a column block and run the macro again.

### Values overwrite nearby text

This is expected: the macro uses overwrite mode. Adjust the marked column block before filling, or work on a backup copy of important data.

### The sequence moves in the wrong direction

Check **Step**. A positive step counts upward; a negative step counts downward.

### The sequence does not stop at the requested value

Ensure that the direction of **Step** agrees with the relationship between **From** and **To**. Note that `To = 0` means that no explicit stopping value is used.

### The source does not compile

Confirm that you are using the SAL compiler supplied for your TSE installation and that the extracted `fillnum.s` file is complete and unchanged.

## Version history

| Version | Date and time | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-08 15:45:38 UTC | Initial Markdown documentation created for `fillnum2.zip`. |

Future documentation revisions can increment the final component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original source history

- 1992-12-08: Initial version.
- 1993-10-29: Bug fixes and speed optimizations.
- 2001-05-24: Fill character and numeric-base support added.

## License notice

The source identifies SemWare as the author and contains a SemWare copyright and distribution notice. Preserve that notice when using, modifying, or redistributing the macro. Refer to the full notice in `fillnum.s` for the applicable conditions.
