# HEXOFS for The SemWare Editor

**Session:** Create HEXOFS MarkDown Readme  
**README version:** 1.0.0.0.0  
**Date:** 10 September 2026  
**Time:** 23:48 CEST  

## Description

HEXOFS is a TSE SAL macro for The SemWare Editor (TSE). When a file is opened in Binary Mode, the macro displays the byte offset of the cursor at the right side of the status line.

The offset can be shown in decimal or hexadecimal notation. HEXOFS also lets you jump directly to a specified byte offset.

The package contains:

- `HEXOFS.S` - SAL source code.
- `HEXOFS.MAC` - compiled TSE macro.
- `HEXOFS.TXT` - original documentation.

## Features

- Displays the current cursor offset while editing in Binary Mode.
- Supports decimal and hexadecimal offsets.
- Toggles between decimal and hexadecimal display.
- Jumps directly to a user-entered byte offset.
- Leaves the original key functions unchanged when Binary Mode is not active.
- Can be loaded automatically whenever TSE starts.

## Requirements

- The SemWare Editor.
- A file opened with TSE Binary Mode enabled.
- The SAL compiler is required only when recompiling `HEXOFS.S`.

## Installation

1. Extract `hexofs.zip` to a working directory.
2. Copy `HEXOFS.MAC` to a directory from which TSE can load macros, such as the TSE `MAC` directory.
3. Load the macro from inside TSE:

   ```text
   LoadMacro("HEXOFS")
   ```

4. Optionally add HEXOFS to the TSE AutoLoad macro list so that it loads automatically when TSE starts.

## How to run HEXOFS

1. Start TSE.
2. Load `HEXOFS.MAC` if it was not loaded automatically.
3. Open a file in Binary Mode.
4. Look at the right side of the status line. HEXOFS displays the offset of the current cursor position.

HEXOFS does not display an offset when Binary Mode is inactive.

## Keyboard commands

| Key | Function |
| --- | --- |
| `Ctrl+Enter` | Prompt for an offset and move the cursor to that byte position. |
| `Ctrl+Shift+Enter` | Toggle the displayed and entered offset base between decimal and hexadecimal. |

When the file is not in Binary Mode, these key combinations are passed to their previously assigned TSE commands.

## Decimal and hexadecimal modes

HEXOFS starts in decimal mode.

- In decimal mode, the status line shows the offset as a decimal number.
- In hexadecimal mode, the status line prefixes the value with `0x`.
- The `Goto offset` prompt states whether the entered value must be decimal or hexadecimal.

Press `Ctrl+Shift+Enter` to switch between the two modes.

## Jumping to an offset

1. Make sure the file is open in Binary Mode.
2. Select decimal or hexadecimal mode with `Ctrl+Shift+Enter`.
3. Press `Ctrl+Enter`.
4. Enter the required offset in the base shown by the prompt.
5. Press `Enter`.

The macro calculates the corresponding binary line and column and moves the cursor to that position.

## Recompiling the source

To modify the macro or its key assignments, edit `HEXOFS.S` and compile it with the TSE SAL compiler. For example:

```text
sc32 HEXOFS.S
```

If compilation succeeds, the compiler creates a new `HEXOFS.MAC`. Restart TSE or purge and reload the macro before testing the newly compiled version.

## Changing the key assignments

The default key definitions are at the end of `HEXOFS.S`:

```text
<Ctrl Enter>        if BinaryMode() > 0 mGotoOfs() else ChainCmd() endif
<CtrlShift Enter>   if BinaryMode() > 0 mToggleBase() else ChainCmd() endif
```

Edit these definitions if the default keys conflict with other macros, then recompile the source.

## Important limitation

HEXOFS calculates an offset from the current binary line length, line number, and column number. It assumes that every line in the Binary Mode display has the expected length.

If a binary line is edited so that it becomes longer or shorter than the configured Binary Mode line length, the displayed and calculated offsets may be incorrect. Take care when modifying binary files and avoid changing their displayed line structure.

## Unloading the macro

When HEXOFS is purged or unloaded, it removes its status-line hook. Use TSE's normal macro purge or unload mechanism if the offset display is no longer required.

## Troubleshooting

### No offset is displayed

- Confirm that `HEXOFS.MAC` is loaded.
- Confirm that the current file is open in Binary Mode.
- Refresh the display or move the cursor.

### The reported offset is incorrect

- Check whether one or more binary display lines were made longer or shorter.
- Reopen the file without altering the Binary Mode line structure.

### A keyboard shortcut performs another command

- Confirm that Binary Mode is active.
- Check for another macro that overrides the same keys.
- Change the key definitions in `HEXOFS.S` and recompile it if necessary.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 10 September 2026, 23:48 CEST | Initial Markdown README with description, installation, operation, keyboard commands, recompilation steps, limitations, and troubleshooting. |

Future revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.
