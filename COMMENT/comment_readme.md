# COMMENT — SAL Commenting Macro for TSE Pro/32

**README version:** 1.0.0.0.0  
**Date:** 2026-09-03  
**Time:** 00:33:46 UTC  
**Original macro date:** 2001-12-12  
**Author:** Peter Kraemer  
**Compatibility stated by the original package:** TSE Pro/32 version 2.8 or later

## Description

`COMMENT` is a TSE SAL macro for creating and maintaining standardized framed comments in SAL source files. It recognizes procedure-type structures such as procedures, menus, key definitions, data definitions, and help definitions.

The macro can create, update, edit, reframe, or delete procedure comments. It can also generate information automatically, including procedure names, caller lists, parameters, and return-value descriptions.

The supplied ZIP archive contains:

- `comment.s` — the TSE SAL source code.
- `file_id.diz` — the original short package description.

## Main features

### Procedure comments

- Creates standardized framed comments above SAL structures.
- Updates existing comments.
- Automatically builds or updates the `Called by:` list.
- Checks procedure parameters and return values.
- Supports automatic, prompted, or disabled processing for individual items.
- Allows the frame style, dimensions, and text positions to be customized.
- Works on the current procedure, all following procedures, or the entire file.

### Additional comments

- Inserts an independent framed comment between procedures.
- Places a marked line block inside a comment frame.
- Creates headline comments consisting of a text line between divider lines.
- Edits individual comment sections or the complete comment body.

### Source formatting and navigation

- Removes empty lines inside procedure-type structures.
- Removes duplicate empty lines outside those structures.
- Moves to the previous or next procedure.
- Displays a procedure pick list for quick navigation.
- Activates its menu key only for `.s` and `.ui` files by default.

## Important safety notes

The macro directly modifies the active SAL source file.

1. Make a backup copy before using the macro.
2. Compile the SAL source successfully before adding or updating comments. The macro relies on recognizable procedure boundaries, and invalid source may produce unpredictable results.
3. Save and recompile the source after commenting to confirm that no code was affected.
4. Test the macro on a copy of a source file before applying it to important projects.

## Installation

### 1. Extract the archive

Extract `comment.zip` to a working directory. Confirm that `comment.s` is present.

### 2. Compile the macro

Compile `comment.s` with the SAL compiler supplied with your TSE installation. From a command prompt in the directory containing the file, a typical command is:

```bat
sc32 comment.s
```

This should produce the compiled TSE macro file, normally `comment.mac`.

If `sc32` is not in `PATH`, run it by its full path or compile the source using your normal TSE SAL build procedure.

### 3. Make the compiled macro available to TSE

Place `comment.mac` in a directory from which TSE loads macros, or load it by using TSE's macro-loading facility. The exact menu wording can vary by TSE version and configuration.

For regular use, add `COMMENT` to your normal macro autoload configuration so its `WhenLoaded()` procedure runs when TSE starts.

### 4. Open a supported source file

Open a SAL source file whose extension is `.s` or `.ui`. The macro enables its menu key only for these extensions by default.

## How to run

1. Open a valid `.s` or `.ui` SAL source file in TSE.
2. Put the cursor inside or near the procedure-type structure that you want to document.
3. Press **F12** to open the `COMMENT` configuration and command menu.
4. Choose the required operation.
5. Press **Escape** to leave the menu.
6. Save and recompile the edited source file.

The default activation key is defined in `comment.s` as:

```sal
constant _MENU_KEY = <F12>
```

Change this constant and recompile the macro if **F12** conflicts with another key assignment.

## Menu reference

### Configuration

- **Positions** — changes frame borders and the columns used for comment fields.
- **Keywords** — changes the text used for `Called by:`, `Enter with:`, `Returns:`, and `Notes:` fields.
- **Query** — selects automatic, prompted, or disabled handling for each update category.
- **1-Style** — selects the frame style for procedure comments.
- **2-Style** — selects the frame style for additional comments.
- **Silent** — controls whether the macro asks about missing information.
- **Mode** — selects the current procedure, the procedures below the cursor, or the whole file.

### Comment operations

- **Update** — creates or fully updates procedure comments.
- **Frame** — creates or refreshes only the comment frame.
- **Delete** — removes procedure comments in the selected work mode.
- **Insert** — inserts an additional framed comment.
- **Block** — asks for a line block and frames the marked text as a comment.
- **Headline** — creates a headline between two divider lines.
- **White Space** — normalizes empty lines inside and outside procedures.

### Editing

- **All** — edits all text inside the current comment frame.
- **Title** — edits the comment title.
- **Leading Text** — edits the main description.
- **Called by** — edits the caller information.
- **Enter with** — edits parameter information.
- **Returns** — edits return-value information.
- **Notes** — creates or edits notes.

### Navigation

- **+ Forward** — moves to the next procedure.
- **- Backward** — moves to the previous procedure.
- **# Pick List** — opens a procedure list and jumps to the selected entry.

## Recommended first run

For a large source file, enable **Silent** mode and select the desired work mode before choosing **Update**. This lets the macro generate frames and mechanically derived fields without stopping at every empty text item. Afterwards, review and edit the descriptions and notes manually.

Changing the configured style does not automatically restyle existing comments during an ordinary update. Use **Frame** when you want an existing frame to adopt a different style.

## Customization

Most initial settings are in the `DEFAULTS` section near the beginning of `comment.s`. They include:

- Activation key.
- Supported filename extensions.
- Procedure and additional-comment frame styles.
- Left and right frame columns.
- Text-field positions.
- Silent and query behavior.
- Default work mode.
- Keywords for generated comment fields.

The default supported extensions are:

```sal
string STR_EXTENSIONS_[] = "|.s|.ui|"
```

The original source uses extended ASCII line-drawing characters and an optional `Chr(0)` marker in headline comments. Preserve the source file's legacy character encoding when editing it; converting it blindly to UTF-8 may damage those characters in older TSE environments. To use a normal space after `//` in headline comments, change `_HEAD_MARK` from `0` to `32` and recompile.

## Troubleshooting

### F12 does not open the menu

- Confirm that the compiled macro is loaded.
- Confirm that the active file has a `.s` or `.ui` extension.
- Check whether another macro already uses **F12**.
- Change `_MENU_KEY` if necessary, then recompile and reload the macro.

### Compilation fails after editing `comment.s`

- Restore the original file encoding.
- Check that line-drawing characters or embedded marker characters were not converted or removed.
- Compile with a SAL compiler compatible with your TSE installation.

### Unexpected source changes occur

- Undo the operation immediately or restore the backup.
- Verify that the original SAL source compiles without errors.
- Try the operation first in **current procedure** mode instead of whole-file mode.
- Recompile the result before accepting the changes.

### New style settings do not affect old frames

Use **Frame** on the existing comment. A normal **Update** retains the current frame type.

## Unloading

Unload or purge `COMMENT` through TSE's macro-management facility if you no longer want it active. Its `WhenPurged()` procedure releases the macro's internal pick-list buffer.

## Version history

| Version | Date | Description |
|---|---|---|
| 1.0.0.0.0 | 2026-09-03 | Initial Markdown README created from `comment.s` and `file_id.diz`. |

Future documentation revisions should increment the final component sequentially:

- `1.0.0.0.1`
- `1.0.0.0.2`
- `1.0.0.0.3`
- and so on.

## Disclaimer

This is a legacy macro that modifies source files in place. Keep backups and verify all resulting source by recompiling it. The original author disclaimed responsibility for damage to or loss of SAL source code caused by use of the macro.
