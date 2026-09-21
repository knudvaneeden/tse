# MAKE_PG1

Version: 1.0.0.0.1  
Updated: 2026-09-21 10:47:01 UTC  
Documented with: OpenAI Codex (GPT-5)

## Description

`MAKE_PG1.S` is a legacy TSE SAL macro that paginates a flat ASCII text file. It inserts a formatted header and a second separator line at the start of each page. It can also insert form-feed characters at page boundaries.

The macro supports automatic and interactive page-break placement. In automatic mode it can search backward for a blank line within a configurable range, helping prevent a page break in the middle of a paragraph or code section. In interactive mode it proposes a position and lets you move the cursor before accepting the break.

Inserted lines are marked with a configurable line-ID character. The preprocessing mode can later find that character and remove previously inserted headers, separator lines, and form-feed lines before repaginating the file.

## Important warning

MAKE_PG1 changes the contents of the active or selected file. Make a backup before running it. If interactive processing is aborted, changes already made remain in the editor buffer. Reloading the unchanged disk file can discard those partial edits if it has not been saved.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- A writable text file open in TSE.
- The source must remain in its original single-byte/ASCII-compatible encoding. Do not convert the legacy line-ID and separator characters to UTF-8.

## Package contents

- `MAKE_PG1.S` - TSE SAL source code.
- `make_pg1.ini` - initial settings reference file.
- `make_pg1_readme.md` - this documentation.

## Compilation

1. Extract all files from `make_pg11.0.0.0.1.zip` into one directory.
2. Open a command prompt in that directory.
3. Compile the macro with the TSE SAL compiler:

   ```text
   sc32 MAKE_PG1.S
   ```

4. Confirm that the compiler creates `MAKE_PG1.MAC` without errors.
5. Put `MAKE_PG1.MAC` in a directory from which TSE loads or executes macros.

## How to run

1. Open the text file that you want to paginate in TSE.
2. Make sure a backup copy exists.
3. Execute the compiled macro as `MAKE_PG1` using TSE's normal macro execution command.
4. Review the menu settings described below.
5. Select `eXecute` to process the file, or `Abort` to leave without starting.
6. Inspect the result before saving the modified file.

## Menu options

### Target and header

- **Target file spec**: Defaults to the current filename. A different path and filename may be entered. If it does not resolve directly to a file, the macro opens a file-selection list for the specified path.
- **User comment**: Optional text placed in the page header.
- **Date**: Includes or omits the current date in the header.
- **Page Numbers**: Includes or omits `page n of total` information. After pagination, the macro fills in the total page count.
- **Leadin**: Optional characters placed at the start of generated lines, such as `//` for a TSE SAL source file or `;` for assembly source.
- **Second line fill character**: Character used for the separator line below each header.
- **Header width**: Controls header spacing and separator width. The source identifies 74 as the minimum.

### Page breaks

- **Number of Lines per page**: Desired page length. The initial value is 65.
- **Condition Page Break offset**: Number of lines before the nominal page boundary in which the macro may use a blank line. The initial value is 8. Enter 0 to disable conditional placement.
- **Write Form Feed Characters in file**: Enables or disables insertion of ASCII form-feed characters.
- **INTERACTIVE mode**: Lets you confirm or adjust each proposed break position.

### Preprocessing

- **Remove all lines with line ID character**: Removes generated lines containing the selected line-ID character before new pagination begins.
- **Exit after pre_process**: Stops after removing old generated lines instead of paginating again.
- **Line ID character**: Marker used to recognize generated lines. The original default is ASCII 255. Choose a character that does not otherwise occur in the file.

## Interactive-mode keys

When interactive mode is active, only these keys are handled:

- `Cursor Up` or `Ctrl+E`: Move the proposed page break up one line.
- `Cursor Down` or `Ctrl+X`: Move the proposed page break down one line.
- `Enter`: Accept the current position and insert the page break/header.
- `Esc`: Abort processing. Any changes already inserted remain in the buffer.

The status line shows the current file line, page number, and line number within the page.

## Removing old pagination

To strip lines previously inserted by MAKE_PG1:

1. Run `MAKE_PG1` on the file.
2. Set **Remove all lines with line ID character** to `YES`.
3. Set **Exit after pre_process** to `YES` if you only want to remove the old pagination.
4. Verify that the selected line-ID character matches the one used when the file was paginated.
5. Select `eXecute` and inspect the result before saving.

The preprocessing search removes every line containing the line-ID character. Using an ID that also appears in normal document text can therefore delete legitimate lines.

## About `make_pg1.ini`

`make_pg1.ini` records clear initial values for future configuration work. The supplied legacy `MAKE_PG1.S` source does **not** read this file; its active defaults are currently defined directly in the SAL source. Editing the INI file alone will not change the macro's behavior in version 1.0.0.0.1.

## Version history

- **1.0.0.0.1** - Updated the legacy `Sound(800)` call to `Sound(800, 1)` for compatibility with the current TSE SAL compiler.
- **1.0.0.0.0** - Initial documented package with README and INI reference file.

## Original macro history

The source identifies the original program as MAKE_PG version 1.0 by G. Grafton Cole/GRAFCO Inc., initially dated 20 January 1994. Its comments record later changes in 1994 for preprocessing, interactive calculations, marking the separator line, target paths, and line-ID selection.
