# MOVE_1

Version: 1.0.0.0.2  
Package date and time: 2026-09-22 18:29:20 UTC  
Original source: `MOVEMENT.S`, by "Buddy" E. Ray Asbury, Jr. (1993)  
Package update: OpenAI Codex

## Description

MOVE_1 is a TSE SAL movement-procedure library. It supplies improved cursor and marked-block navigation routines that another SAL macro can call.

The package contains:

- `MOVEMENT.S` - ASCII SAL source code.
- `move_1.ini` - startup-message configuration.
- `move_1_readme.md` - this documentation.

## Procedures

### `mGotoLocation(row, column)`

Moves to an absolute line and/or column, or moves by a relative offset. Pass the line and column as strings.

Examples:

```text
mGotoLocation("10", "46")
mGotoLocation("+10", "46")
mGotoLocation("10", "+5")
mGotoLocation("", "20")
mGotoLocation("20", "")
mGotoLocation("", "")
```

When both arguments are empty, MOVE_1 asks for a location. Interactive examples include `12`, `,13`, `12,13`, `+12`, and `,-13`.

### `mGotoBlockBegin()`

Moves to the exact beginning of the marked block in the current file. This includes the block's beginning column.

### `mGotoBlockEnd()`

Moves to the exact end of the marked block in the current file. This includes the block's ending column.

### `mGotoWord(direction)`

Moves to the first character of the previous or next actual word, continuing across line boundaries when necessary.

Use one of the source constants:

```text
kPREVIOUS_WORD
kNEXT_WORD
```

## Configuration

`move_1.ini` must remain in the same directory as the compiled macro. Its default content is:

```ini
[move_1]
silent=false
```

- `silent=false` shows an informative `Warn()` box when the macro is run directly.
- `silent=true` suppresses that startup box.

The setting is case-insensitive. Keep the setting as `silent=true` or `silent=false` without spaces around the equals sign.

## Compile and install

1. Extract all files from `move_11.0.0.0.2.zip` into one directory.
2. Open a command prompt in that directory.
3. Compile the source with:

   ```bat
   sc32 MOVEMENT.S
   ```

4. Confirm that `MOVEMENT.MAC` was created without compiler errors.
5. Keep `move_1.ini` beside `MOVEMENT.MAC`.
6. Load `MOVEMENT.MAC` in TSE through your normal macro-loading method.

The source does not use `LoadDir()`. The INI pathname is derived from the running macro's directory, so the package can be moved as a unit.

## How to run it

Run `MOVEMENT.MAC` directly to display the informational startup message. MOVE_1 does not move the cursor merely by being run or loaded; its movement procedures are intended to be called by another SAL macro.

A calling macro can include the source during compilation:

```text
#include ["MOVEMENT.S"]
```

It can then call one or more of the procedures documented above. Alternatively, copy the required procedures into a larger SAL project, subject to the original public-domain notice in `MOVEMENT.S`.

## Notes

- The SAL source is stored as ASCII, not UTF-8.
- No default hotkeys are assigned.
- The original movement logic and public-domain notice are retained.
- `mGotoLocation()` returns `TRUE` after a successful move and `FALSE` when no move is made or a requested position is outside the supported range.

## Version history

### 1.0.0.0.2 - 2026-09-22

- Changed the location prompt to use TSE's built-in `_EDIT_HISTORY_`.
- Removed the custom history variable and `GetFreeHistory()` call.

### 1.0.0.0.1 - 2026-09-22

- Corrected `GetFreeHistory()` to `GetFreeHistory("MOVE_1_LOCATION")` for TSE SAL 4.50 compatibility.
- Fixed compiler errors 2204 and 2302 at the history initialization line.

### 1.0.0.0.0 - 2026-09-22

- Added this Markdown documentation.
- Added `move_1.ini` with `silent=false` as the default.
- Added a portable `Main()` startup message controlled by the INI setting.
- Converted the legacy source text to ASCII for modern TSE SAL compilation.
- Kept the original movement procedures and public-domain notice.
