# I_CMMT10 - Intelligent Commenting for TSE

Session: `Create I_CMMT10 MarkDown Readme`  
README version: `1.0.0.0.4`  
Date: `2026-09-11`  
Time: `22:50:46 CEST`  
Original macro version: `1.0`  
Original author: John D. Goodman

## Description

I_CMMT is an Intelligent Commenting macro package for The SemWare Editor (TSE). It adds context-sensitive commands for commenting and uncommenting source code.

The package supports three main operations:

- In-line comments, such as `//`, `REM`, `;`, `&&`, or another user-defined string.
- Full-line comments inserted above the current line.
- Block comments inserted above and below marked text, such as `/*` and `*/`.

The macro changes its behavior according to the cursor position, the presence and type of a marked block, and whether the first selected line is already commented.

## Files in the archive

- `I_CMMT.S` - TSE SAL source code.
- `I_CMMT.DOC` - original detailed documentation.

## Default keys

| Key | Command | Action |
| --- | --- | --- |
| `Alt+8` | `InLineCmmt()` | Adds or removes in-line comments. |
| `Alt+9` | `FullLineCmmt()` | Adds a full-line comment or surrounds marked lines with a block comment. |
| `Alt+0` | `CmmtOptsMenu()` | Opens the commenting options menu. |

The key assignments are at the end of `I_CMMT.S` and can be changed before compilation.

## How in-line commenting works

Press `Alt+8` on the current line or within a marked block.

- If the first selected line is not commented, the macro comments the selected line or lines.
- If the first selected line is already commented, the macro removes comments from the selected lines.
- If no block is active and the cursor is at or beyond the end of a non-blank line, the macro inserts an end-of-line comment at the cursor.
- A line block uses the configured default comment column.
- A character or column block uses the block's starting column.
- If the selected comment column would split existing text, the macro uses column 1 instead.

The default in-line comment string is:

```text
// 
```

## How full-line and block commenting works

Press `Alt+9`.

- With no active marked block, a full-line comment is inserted above the current line.
- With a multi-line marked block, beginning and ending block-comment lines are inserted around the selection.
- A line block uses the default comment column.
- A character or column block uses the block's starting column.

The default block-comment definition is:

```text
/*|*/
```

The vertical bar separates the beginning and ending strings.

## Comment options

Press `Alt+0` to configure:

- The in-line and full-line comment string.
- Block-comment beginning and ending strings.
- Fixed or prompted full-line/block comment text.
- The default comment column; a value of `0` uses the current left margin.
- Blank-line handling: `None`, `Normal`, or `Smart`.
- Optional word wrapping during commenting and uncommenting.
- TSE right margin, left margin, AutoIndent, paragraph-end style, and normal word-wrap mode.

The default blank-line mode is `Smart`, and automatic word wrapping while commenting is off.

## Special indicators

Comment strings can contain special indicators that are expanded when a comment is created:

| Indicator | Meaning |
| --- | --- |
| `\t` | Inserts a tab in an in-line or block comment string. |
| `\d` | Inserts the current system date. |
| `\h` | Inserts the current system time. |
| `\p` | Prompts for text when an in-line comment is inserted. |
| `\\` | Inserts a literal backslash. |

Dynamic date, time, or prompted text can make automatic uncommenting more difficult because the expanded comment differs from the configured template.

## Decorative full-line comments

If full-line comment text begins or ends with one of these characters, the macro extends that character toward the current right margin:

```text
-=*^~.:+#
```

For example, with `// ` as the in-line comment string, entering `-` as the full-line comment text produces a separator similar to:

```text
// ---------------------------------------------------------------
```

## Installation and compilation

1. Extract `i_cmmt10.zip` to a working directory.
2. Keep `I_CMMT.S` and `I_CMMT.DOC` together for convenient reference.
3. Open a command prompt in that directory.
4. Compile the SAL source with the TSE SAL compiler:

   ```bat
   sc32 I_CMMT.S
   ```

5. Confirm that the compiler creates `I_CMMT.MAC` without errors.
6. Copy `I_CMMT.MAC` to the directory from which you load TSE macros, if required by your setup.
7. Load `I_CMMT.MAC` from TSE's macro menu or add it to your normal macro-loading configuration.

The source was originally written for a TSE 1.0 pre-release in 1994. Version `1.0.0.0.4` supplies the history-name argument required by TSE 4.50 and replaces the unsupported `Toggle(WordWrap)` menu action with an explicit `Set()` operation.

## Steps to run and test

### Test in-line commenting

1. Open a test source file in TSE.
2. Put the cursor at the beginning of a line containing code.
3. Press `Alt+8`.
4. Confirm that `// ` is inserted at the beginning of the line.
5. Press `Alt+8` again on that line.
6. Confirm that the comment string is removed.

### Test a marked group of lines

1. Mark several complete lines.
2. Keep the cursor inside the marked block.
3. Press `Alt+8`.
4. Confirm that every selected line is commented.
5. Mark or select those lines again and press `Alt+8` to uncomment them.

### Test an end-of-line comment

1. Place the cursor after the final character of a non-blank line.
2. Press `Alt+8`.
3. Confirm that the comment string is inserted at the cursor and that you can type the comment text immediately.

### Test a block comment

1. Mark two or more lines.
2. Keep the cursor inside the marked block.
3. Press `Alt+9`.
4. Enter comment text when prompted, unless fixed text was configured in the options menu.
5. Confirm that the macro inserts a beginning comment line above the block and an ending comment line below it.

### Test another programming language

1. Press `Alt+0`.
2. Change the in-line comment string, for example to `REM ` for a batch-style source file.
3. Close the options menu.
4. Press `Alt+8` on a test line and verify the result.

## Notes and limitations

- Uncommenting is decided from the first selected line.
- Only the first matching comment string at the beginning of each selected line is removed.
- Existing leading whitespace is ignored when detecting comments.
- Comment matching is not case-sensitive, which is useful for strings such as `REM`.
- Marked blocks are normally unmarked when an operation finishes.
- Word wrapping uses the current TSE margin, indentation, and paragraph settings.
- The original author describes the supplied documentation as incomplete.
- Test the macro on disposable files or backups before using it on important source code.

## Version history

### 1.0.0.0.4 - 2026-09-11 23:13 CEST

- Replaced `Toggle(WordWrap)`, which TSE 4.50 rejects, with `Set(WordWrap, iif(Query(WordWrap), OFF, ON))`.
- Preserved the original on/off behavior of the Normal Wordwrap Mode menu option.

### 1.0.0.0.3 - 2026-09-11 23:12 CEST

- Corrected `GetFreeHistory` according to its TSE 4.50 syntax: `GetFreeHistory(STRING history_name)`.
- Assigned unique `I_CMMT:` names to the four private histories.
- Restored the original `REM`, `;`, `&&`, `*`, `//`, and `/*|*/` history choices.

### 1.0.0.0.2 - 2026-09-11 23:09 CEST

- Replaced the incompatible `GetFreeHistory` and `AddHistoryStr` initialization with `_EDIT_HISTORY_`.
- The four prompts now share TSE's standard edit history.

### 1.0.0.0.1 - 2026-09-11 22:56 CEST

- Updated all four obsolete `GetFreeHistory()` calls for TSE 4.50.
- Added the updated source version and compiler-compatibility note.

### 1.0.0.0.0 - 2026-09-11 22:50:46 CEST

- Created the Markdown description and help file.
- Documented installation, compilation, configuration, shortcuts, special indicators, and tests.
- Based the instructions on `I_CMMT.S` and `I_CMMT.DOC` from `i_cmmt10.zip`.

Future updates can continue with `1.0.0.0.5`, `1.0.0.0.6`, and so on.
