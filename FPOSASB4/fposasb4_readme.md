# FPOSASB4

**Session:** Create FPOSASB4 MarkDown Readme  
**README version:** 1.0.0.0.1  
**Date:** 2026-09-10  
**Time:** 01:13 CEST (23:13 UTC)

## Description

FPOSASB4 is a TSE SAL macro by Steven Saunderson. It remembers the view and cursor position of each edited file when that file is unloaded or when TSE closes. When the file is opened again, the macro restores:

- The current line
- The cursor column
- The cursor's row on the editor screen

The saved information is stored in TSE's persistent history. This makes it possible to resume work at approximately the same visible position without manually navigating back to it.

## Files in the archive

- `FPOSASB4.S` - TSE SAL source code
- `FILE_ID.DIZ` - Original short package description

## Requirements

- The SemWare Editor (TSE) with SAL macro support
- The matching TSE SAL compiler, such as `SC32.EXE`
- TSE's `PersistentHistory` option enabled
- An available history sub-list ID from 1 through 127

The source uses history list ID `127`. If another installed macro already uses that ID, change the `ListID` value in `FPOSASB4.S` to an unused value before compiling.

## How it works

FPOSASB4 installs three TSE event hooks:

- `_ON_FIRST_EDIT_` restores the saved position when a file is first edited after loading.
- `_ON_FILE_QUIT_` saves the position when a file is unloaded.
- `_ON_EXIT_CALLED_` saves the positions of all open files when TSE closes.

Only positions away from the beginning of a file are stored. An older entry for the same filename is removed before a new entry is added. The maximum number of remembered files is controlled by TSE's `MaxHistoryPerList` setting.

## Installation and compilation

1. Extract `fposasb4.zip` to a working directory.
2. Open a command prompt in that directory.
3. Compile the SAL source:

   ```text
   sc32 fposasb4.s
   ```

4. Confirm that the compiler creates the compiled TSE macro file.
5. Put the compiled macro where your TSE installation can load it.
6. Add FPOSASB4 to TSE's AutoLoad macro list.
7. Verify that `PersistentHistory` is enabled in TSE.
8. Restart TSE, or load the compiled macro using your normal TSE macro-loading method.

FPOSASB4 has no interactive main command and is intended to remain loaded through AutoLoad so that its event hooks operate automatically.

## How to use it

1. Open a file in TSE.
2. Move to a line and column away from the beginning of the file.
3. Unload the file, or close TSE normally.
4. Open the same file again.
5. Begin editing the file. FPOSASB4 should restore the saved line, column, and screen row automatically.

No keyboard shortcut or command is required during normal use.

## Configuration

The following values appear near the beginning of `FPOSASB4.S`:

```text
integer ListID = 127
string  sep [1] = Chr (0x10)
```

- `ListID` selects the TSE history sub-list. TSE requires a value from 1 through 127.
- `sep` separates the filename, line, column, and row in each saved history entry. The separator character must not occur in a filename.
- `MaxHistoryPerList` is a TSE setting that determines the maximum number of saved entries.

## Help and troubleshooting

### The position is not restored

- Confirm that FPOSASB4 is compiled and included in the AutoLoad list.
- Confirm that `PersistentHistory` is enabled.
- Close TSE normally so that its persistent history can be written.
- Make sure the file is reopened with the same full filename and path.
- Start editing the loaded file so that the `_ON_FIRST_EDIT_` hook runs.

### Positions disappear for older files

Increase TSE's `MaxHistoryPerList` setting if you want FPOSASB4 to remember more files. The macro shares this limit with the selected history sub-list.

### Another macro behaves incorrectly

Another macro may be using history list ID `127`. Change `ListID` in the source to a different unused number from 1 through 127, then recompile FPOSASB4.

### The beginning of a file is not saved

This is intentional. The original source only creates an entry when the combined line, column, and screen-row values indicate that the position is not at the beginning of the file.

## Compatibility

The original package states that it was tested with TSE 2.5 and TSE 3.0. Later TSE versions may also compile and run it, but should be tested with the SAL compiler supplied for that version.

## Version history

### 1.0.0.0.0 - 2026-09-10 01:13 CEST

- Created the initial Markdown description, help, installation instructions, and usage guide from the supplied FPOSASB4 archive.

### 1.0.0.0.1 - 2026-09-10 01:13 CEST

- Added detailed hook behavior, configuration notes, compatibility information, and troubleshooting guidance.

## Original program information

- **Macro name:** FPosAsB4
- **Author:** Steven Saunderson
- **Original source date:** 2001-05-08
- **Original tested versions:** TSE 2.5 and TSE 3.0

