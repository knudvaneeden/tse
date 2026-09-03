# COMMENT5 — TSE Commenter Macro

**README version:** 1.0.0.0.0  
**Date:** 2026-09-03  
**Time:** 02:52:14 CEST (00:52:14 UTC)  
**Original macro:** COMMENT5.S, Commenter version 0.05  
**Original release date:** 1993-06-25  
**Original author:** Thomas A. Klein (Tom Klein)

## Description

COMMENT5 is a source macro for The SemWare Editor (TSE). It adds a selected comment prefix to the beginning of the current line or every line in a marked block.

The macro combines the original commenting and reblocking code in one standalone source file. A line-marked block is converted to a column block before the text is shifted and the comment characters are inserted.

Available prefixes are:

- `// `
- `:  `
- `:: `
- `REM`
- `;  `
- Three spaces

The default prefix is `// `. The selected prefix remains active until it is changed through the Commenter menu or the macro is purged.

## Included files

| File | Description |
| --- | --- |
| `COMMENT5.S` | Complete TSE macro source code |
| `FILE_ID.DIZ` | Short description from the original archive |

## Features

- Comments the current line when no block is marked.
- Comments all lines in a marked block.
- Supports line, column, and other block selections handled by the macro.
- Offers several common comment formats.
- Can shift text by three spaces, or four spaces for `REM`.
- Can optionally rewrap the paragraph when TSE WordWrap is enabled.
- Allows the left and right margins to be viewed and changed.
- Contains its required reblocking code and needs no external `reblock.s` file.

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- A TSE/SAL version capable of compiling this legacy 1993 source.

This is historical SAL source. Modern TSE compiler releases may report deprecated syntax, warnings, or errors. If that happens, the source must be updated for the installed compiler before it can be used.

## Installation and compilation

1. Extract `comment5.zip` to a working directory.
2. Locate `COMMENT5.S`.
3. Compile the source with the TSE SAL compiler. For a current 32-bit compiler, try:

   ```text
   sc32 COMMENT5.S
   ```

4. If compilation succeeds, place or keep the resulting compiled macro where TSE can load it.
5. Start TSE, or restart it if an older copy of the macro is still loaded.
6. Load or execute the compiled COMMENT5 macro using your normal TSE macro-loading method.

The exact output extension and loading command can depend on the TSE version and local configuration.

## How to run it

### Comment the current line

1. Place the cursor on the line to be commented.
2. Press `Shift+CenterCursor` (the centre key on the numeric keypad).
3. Keep Num Lock enabled, as noted in the original source.

When no block is marked, COMMENT5 marks and comments the current line automatically. It then moves to the following line, which makes repeated single-line commenting convenient.

### Comment a marked block

1. Mark the lines or columns to be commented.
2. Press `Shift+CenterCursor`.
3. COMMENT5 shifts the selected text and inserts the active prefix at the left side of every selected line.

### Open the Commenter menu

Press `Shift+CursorDown`.

The menu provides the following commands:

- Add a comment to the block.
- Select the comment prefix.
- Toggle WordWrap.
- View or set the right margin.
- View or set the left margin.
- Purge the macro from memory.

### Change the comment prefix

1. Press `Shift+CursorDown`.
2. Choose **Select Char.**
3. Select `// `, `:  `, `:: `, `REM`, `;  `, or three spaces.
4. Comment the current line or a marked block.

### Change the margins

- Press `Shift+CursorLeft` to set the left margin.
- Press `Shift+CursorRight` to set the right margin.

The same settings are available from the Commenter menu.

## Default key bindings

| Key | Action |
| --- | --- |
| `Shift+CursorDown` | Open the Commenter menu |
| `Shift+CursorLeft` | Set the left margin |
| `Shift+CursorRight` | Set the right margin |
| `Shift+CenterCursor` | Comment the current line or marked block |

These bindings come from the original source and may conflict with an existing TSE configuration. Edit the key definitions near the end of `COMMENT5.S` if different bindings are required, then recompile the macro.

## Word wrapping

When TSE WordWrap is enabled, COMMENT5 calls `WrapPara()` after shifting the selected text. The original author recorded two limitations:

1. With a column block, lines newly added by `WrapPara()` may not receive comment characters.
2. With a line-marked block, an extra comment line may be added when `WrapPara()` does not add a line.

Disable WordWrap from the Commenter menu if this behavior is undesirable.

## Important behavior and limitations

- The macro adds comment characters; it does not provide a dedicated uncomment command.
- The three-space selection indents the text without adding a visible comment character.
- `REM` shifts the text four columns because its prefix occupies three characters without the trailing space used by the other formats.
- The macro modifies the active buffer. Save or back up important files before testing it.
- COMMENT5 was written for an early TSE/SAL environment, so compatibility with a current compiler is not guaranteed without source changes.

## Troubleshooting

### The key does nothing

- Confirm that the macro compiled and loaded successfully.
- Confirm that Num Lock is enabled when using the numeric keypad centre key.
- Check whether another macro or keyboard configuration overrides the same key.
- Open the Commenter menu with `Shift+CursorDown` and select **Add comment to Block** directly.

### The wrong prefix is inserted

Open the Commenter menu and use **Select Char.** The initial default is `// `.

### Text wraps unexpectedly

Open the Commenter menu and switch WordWrap off, or adjust the left and right margins before commenting.

### The current compiler reports errors

The source dates from 1993 and uses legacy SAL syntax. Review each compiler message and modernize only the incompatible constructs. Preserve an untouched copy of the original source for reference.

## Version history

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-03 | Initial Markdown documentation for `comment5.zip` and COMMENT5 v0.05 |

Future documentation revisions should increment only the final component, for example:

- `1.0.0.0.1`
- `1.0.0.0.2`
- `1.0.0.0.3`

## Original macro revision summary

- **1993-06-25 — COMMENT5 v0.05:** First public release; added the three-space option, allowed current-line commenting without a pre-existing block, and retained the selected prefix.
- **1993-06-24 — COMMENT4:** General cleanup; made `// ` the default prefix and added menu-based prefix selection.
- **1993-06-22 — COMMENT4:** Added the Commenter menu, WordWrap control, and left/right margin settings.
- **1993-06-16 — COMMENT3 v0.03:** Replaced custom wrapping code with TSE's internal `WrapPara()`.
- **1993-06-08 — COMMENT2:** Corrected handling of lines added during wrapping.
- **1993-05-30:** Original commenting and reblocking macros by Bob Campbell.

## Safety recommendation

Test COMMENT5 on a copy of a text file first. Review the changed lines before saving, especially when WordWrap is enabled or a column block is used.
