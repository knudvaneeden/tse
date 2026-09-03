# COMPARE4 — TSE File Comparison Macro

**README version:** 1.0.0.0.0  
**Created:** 2026-09-03 17:49:17 UTC  
**Original macro:** `COMPARE.S`, version 1.4 (1993-04-04)  
**Original author:** M. W. Hulse

## Description

`COMPARE.S` is a SemWare Editor (TSE) SAL macro for interactively comparing two text files line by line.

The file that is already open and active in TSE is treated as the **slave file**. When the macro starts, it asks you to open a second file, which becomes the **master file**. The macro displays both files in separate windows and compares the first 255 characters of their corresponding cursor lines.

When the lines differ, the differing portion of the slave line is highlighted. The macro can automatically move upward or downward through both files until it finds the next different line. You can also scroll both files horizontally together or move only the master file vertically to compensate for inserted or deleted lines.

The slave file remains editable while the comparison is active. When you exit, the master file is abandoned and its comparison window is closed.

## Archive contents

| File | Description |
| --- | --- |
| `COMPARE.S` | TSE SAL source code for the comparison macro |

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- A SAL compiler compatible with this older macro source.
- Two text files to compare.

This is legacy SAL source from 1993. Depending on your TSE version, the source might require minor syntax or key-name updates before it compiles.

## Installation and compilation

1. Extract `compare4.zip` to a working directory.
2. Locate `COMPARE.S` in the extracted files.
3. Open a command prompt in that directory.
4. Compile the macro with your TSE SAL compiler. For example:

   ```cmd
   sc32 COMPARE.S
   ```

5. Copy the resulting compiled macro to a directory from which TSE can load macros, or leave it in a directory included in your TSE macro path.

The exact compiled filename and loading method can vary with the TSE version in use.

## How to run

1. Start TSE.
2. Open the file that you want to inspect or modify. This becomes the **slave file**.
3. Run the compiled `COMPARE` macro from TSE.
4. When prompted with `Enter master filename...`, enter or select the file to use as the **master file**.
5. Use the comparison keys described below.
6. Press `Esc` to end the comparison.

The original source also defines the macro-menu assignment `<Alt Q><C>` for starting `mCompare()`.

## Comparison keys

| Key | Action |
| --- | --- |
| `Ctrl+Cursor Up` | Search upward in both files until a differing pair of lines is found |
| `Ctrl+Cursor Down` | Search downward in both files until a differing pair of lines is found |
| `Alt+Grey Cursor Right` | Scroll both file windows four columns to the right |
| `Alt+Grey Cursor Left` | Scroll both file windows four columns to the left |
| `Alt+Grey Cursor Up` | Move only the master file upward by one line |
| `Alt+Grey Cursor Down` | Move only the master file downward by one line |
| `Esc` | Exit comparison mode |

All other keys operate on the slave file only.

> Note: The introductory comment in the source calls the first two shortcuts `Ctrl+Grey Cursor Up/Down`, while the active `KEYDEF` uses `Ctrl+CursorUp` and `Ctrl+CursorDown`. The table above follows the actual active key definitions.

## Typical workflow

1. Open a newer or editable copy of a document as the slave file.
2. Start the macro and select the reference copy as the master file.
3. Press `Ctrl+Cursor Down` to locate the next difference.
4. If one file contains inserted or missing lines, use `Alt+Grey Cursor Up/Down` to realign the master file.
5. Use normal editing keys to correct the slave file if required.
6. Continue searching for differences.
7. Press `Esc` when finished.

## Highlight color

Different text is highlighted using the `NoCompare` color declared near the beginning of `COMPARE.S`:

```sal
NoCompare = Color(Bright White on Red)
```

Change this expression in the source if you prefer another foreground and background color, and then recompile the macro.

## Behavior and limitations

- Only the first 255 characters of each line are compared.
- The comparison is line-oriented; it does not automatically realign inserted or deleted lines.
- The first differing character and the remainder of the visible slave line are highlighted.
- Differences beyond the visible right edge cause both windows to move horizontally to the relevant area.
- Searching stops at the next different line or at the beginning/end of a file.
- During comparison, ordinary editing commands affect only the slave file.
- Exiting abandons the master file. Unsaved changes to the master should therefore be avoided.
- The macro uses legacy TSE key names and commands that may differ in newer TSE releases.

## Troubleshooting

### The macro does not compile

Confirm that you are using the SAL compiler supplied for your TSE version. Because this is older source, check any compiler error for obsolete command syntax or renamed key constants.

### The expected shortcut does not work

Try the active definitions shown in the **Comparison keys** table. Keyboard terminology such as `Grey Cursor` refers to keys on the numeric keypad with Num Lock in the appropriate state.

### The files appear out of alignment

Use `Alt+Grey Cursor Up` or `Alt+Grey Cursor Down` to move only the master file until related lines are opposite each other again.

### A difference after column 255 is not detected

This is an intentional limit of the macro. `GetALine()` retrieves only characters 1 through 255.

### The highlight colors are difficult to read

Modify the `NoCompare` color definition in `COMPARE.S`, then recompile the macro.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-03 17:49:17 UTC | Initial Markdown documentation created from `compare4.zip` and `COMPARE.S` |

Future revisions can continue sequentially as `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Original macro revision history

| Macro version | Date | Changes |
| --- | --- | --- |
| 1.4 | 1993-04-04 | Finds off-screen differences, supports linked horizontal movement, and exits from the master file with `Esc` |
| 1.3 | Not specified | Corrected `Esc` handling while looping, enabled linked horizontal movement, and improved messages |
| 1.2 | Not specified | Added automatic movement through matching lines until a difference is found |
