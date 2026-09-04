# DEM1011 — Designer Enclosures for TSE

**README version:** 1.0.0.0.0  
**Program revision:** 011  
**Date:** 2026-09-04  
**Time:** 21:51:18 UTC  
**Original author:** Hayes Smith

## Description

DEM1011 contains **Designer Enclosures**, a SAL macro for The SemWare Editor (TSE). It adds enclosure characters to text in the current file. The macro can process every line, a marked line block, or the left and right boundaries of a marked column block.

The supplied archive contains both the SAL source and a compiled macro.

## Features

- Encloses text with double quotation marks: `"text"`
- Encloses text with single quotation marks: `` `text' ``
- Supports parentheses, brackets, braces, and angle brackets
- Supports spaces, asterisks, dashes, and periods
- Accepts custom left and right enclosures of up to 80 characters each
- Can process all lines or only a marked line or column block
- Optionally encloses blank lines
- Retains and extends column-block marking after processing
- Includes built-in help
- Can insert special characters through the TSE ASCII-character interface or `chr(number)` notation

## Archive Contents

| File | Description |
| --- | --- |
| `DEM.S` | TSE SAL source code for Designer Enclosures Revision 011 |
| `DEM.MAC` | Ready-to-run compiled TSE macro |
| `FILE_ID.DIZ` | Original short package description |

## Requirements

- The SemWare Editor (TSE) for DOS or Windows, with compatibility for this older TSE-PRO GUI 4.0-era macro
- The TSE SAL compiler (`SC32`) only if you want to rebuild `DEM.MAC` from `DEM.S`

Because this is an older macro, some source statements may require adjustment before compiling with a recent SAL compiler. The supplied `DEM.MAC` can be tried without recompiling it.

## Installation

1. Extract `dem1011.zip` into a temporary directory.
2. Copy `DEM.MAC` to your TSE macro directory.
3. Optionally copy `DEM.S` to the same directory if you want to retain or modify the source.
4. Start or restart TSE if necessary.
5. Load `DEM.MAC` through TSE's macro-loading facility if it is not loaded automatically.

The exact macro directory and loading command depend on your TSE installation and configuration.

## How to Run

1. Open the file that you want to modify in TSE.
2. Optionally mark a line block or column block.
3. Press **Ctrl+Shift+P**. The source defines this key as:

   ```text
   <CtrlShift P> ExecMacro("dem")
   ```

4. Select an enclosure type from the **Designer Enclosures** menu.
5. If a block is marked, choose whether to process all lines or only the marked block.
6. Choose whether blank lines should also be enclosed.
7. Review the result. Use TSE's **Undo** command if you do not want to keep the changes.

You can also run the macro by executing `dem` through TSE's macro execution command.

## Standard Enclosure Choices

| Menu choice | Left | Right |
| --- | --- | --- |
| Quotation marks | `"` | `"` |
| Single quotes | `` ` `` | `'` |
| Parentheses | `(` | `)` |
| Brackets | `[` | `]` |
| Curly braces | `{` | `}` |
| Arrows/angle brackets | `<` | `>` |
| Single spaces | space | space |
| Single asterisks | `*` | `*` |
| Single dashes | `-` | `-` |
| Single periods | `.` | `.` |

## Custom Enclosures

Select **Other** to enter custom left and right enclosure strings. Each side can contain up to 80 characters. Previously entered values are retained in a history list.

At the prompt, use **Ctrl+A** to select special characters from TSE's ASCII-character interface. The macro also recognizes numeric character notation such as:

```text
chr(228)
```

Multiple special characters and ordinary text can be combined, for example:

```text
Leftchr(228)chr(226)
```

The appearance of extended characters depends on the font and character set used by TSE. Some characters may not print or display consistently on modern systems.

## How Blocks Are Handled

### No marked block

The macro asks whether all lines in the current file should be enclosed.

### Marked line block

You can choose to process the entire file or only the marked lines. The enclosure strings are inserted at the beginning and end of each selected line.

### Marked column block

The left and right enclosure strings are inserted at the corresponding column boundaries. The block remains marked and is extended to include the newly inserted enclosure characters.

After undoing a column-block operation, the extended block marking may remain. Re-mark the original column block before repeating the operation.

## Compiling the Source

If your TSE installation includes the 32-bit SAL compiler, open a command prompt in the directory containing `DEM.S` and run:

```bat
sc32 DEM.S
```

If compilation succeeds, the compiler creates or replaces `DEM.MAC`. Copy the resulting file to the appropriate TSE macro directory and load it in TSE.

Keep a backup of the supplied `DEM.MAC` before replacing it. The source dates from 2005 and may use syntax or behavior that differs from a current SAL compiler.

## Help and Troubleshooting

### The menu does not appear

- Confirm that `DEM.MAC` is in a directory where TSE can load macros.
- Load the macro manually through TSE's macro-loading command.
- Run `dem` through TSE's macro execution command.
- Check whether another macro has reassigned **Ctrl+Shift+P**.

### The shortcut conflicts with another macro

Edit the key definition near the beginning of `DEM.S`, recompile the source, and reload the new `DEM.MAC`.

### Blank lines are unchanged

Answer **Yes** when the macro asks whether blank lines should be enclosed.

### Custom extended characters look incorrect

Choose a compatible TSE font and character set. Extended ASCII characters are encoding-dependent and may look different on modern Windows systems.

### Compilation fails

The source was written for an older TSE environment. Use the included compiled `DEM.MAC`, or update the SAL source for the compiler version installed on your computer.

### Cancel or undo an operation

- Press **Esc** at a prompt to cancel the macro.
- Use TSE's **Undo** command after processing to restore the original text.

## Version History

| README version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-04 | Initial Markdown documentation for DEM1011 and Designer Enclosures Revision 011 |

Future documentation revisions should increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## Notes

- Work on a copy of important files until you are familiar with the macro.
- The original package identifies the program as Designer Enclosures Version 1, Revision 11.
- The historical website included in the source may no longer be available.
