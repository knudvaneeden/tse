# MOVEMENTCURSOR01

Version: 1.0.0.0.0  
Created: 2026-09-30 02:00:40 Europe/Amsterdam (UTC+02:00)  
LLM: OpenAI GPT-6 (Codex)  
Requested session title: Create MOVEMENTCURSOR01 Readme

## Purpose

Make cursor movement follow file data. Left and Right use `PrevChar()` and
`NextChar()` to move across line boundaries. Up and Down first move normally,
then bring the cursor back to the insertion position immediately after the
last character only if it is beyond that position.

EOL+1 means `CurrLineLen() + 1`. For a five-character line it is column 6.
Trailing spaces are part of the line; this macro does not trim or skip them.
An empty line has length zero, so its insertion position is column 1.

## Preferred test

Use the cursor position and the actual line length rather than `isWhite()`:

```sal
proc PROCMyCursorDown()
    Down()
    if CurrPos() > CurrLineLen() + 1
        GotoPos(CurrLineLen() + 1)
    endif
end
```

For Up, replace `Down()` with `Up()`. The supplied source shares the clamp
in `PROCClampCursorToLine()`.

`PosLastNonWhite() + 1` describes the position after the last non-whitespace
character. That differs from the end of the file data when trailing whitespace
exists. Whether the current character is whitespace does not reliably answer
whether the cursor is beyond the line.

## Files

- `movementcursor01.s`: ASCII TSE SAL source.
- `movementcursor01.ini`: startup message setting.
- `movementcursor01_readme.md`: description, installation and checks.

No DLL is needed. Compile the source with the compiler for your installed TSE
version; a compiled `.mac` is not supplied.

## Installation and running

1. Extract the ZIP into a directory used for your TSE macros.
2. Keep `movementcursor01.ini` beside the compiled macro.
3. Compile in a command prompt:

   ```text
   sc32 movementcursor01.s
   ```

4. In TSE, invoke Execute Macro and enter `movementcursor01`, or call:

   ```sal
   ExecMacro("movementcursor01")
   ```

5. Dismiss the informative message and try the four arrow keys in a text buffer.
6. For automatic activation, add `movementcursor01` to TSE's startup macro list.

The macro enables a key definition for the ordinary unmodified arrow keys.
Other key definitions enabled later can take precedence. Keep this macro
loaded while using these assignments; do not run it through a helper that
purges it immediately afterward. Restart TSE without its startup entry to
return to your usual assignments, or purge the macro using TSE's macro controls.

## Configuration

```ini
[Settings]
silent=false
```

`silent=false` shows the informative `Warn()` box each time `Main()` runs.
`silent=true` hides that box. It does not disable cursor movement.
The setting is read each time the macro runs. A missing INI or setting defaults
to `false`. The INI path is based on `CurrMacroFilename()`; if its directory is
empty, the current directory is used. The directory separator is checked.

## Movement examples and manual checks

Use a destination line containing exactly `abcde` (length 5):

| Position after normal Up/Down | Final position |
| --- | --- |
| Column 1 | Column 1 |
| Column 3 | Column 3 |
| Column 6 (EOL+1) | Column 6 |
| Column 10 | Column 6 |

Also check:

1. Move from a long line to a shorter one with both Up and Down.
2. Move onto an empty line: the cursor should be at column 1.
3. Move onto a line ending with spaces: the clamp should use its full length.
4. Press Right at EOL+1 and Left at the beginning of a line to cross boundaries.
5. Check the first and last file lines: native Up/Down boundary behavior remains,
   followed by the same clamp on the current line.
6. Run with `silent=false`, then `silent=true`, and check the startup message.

The macro does not maintain a separate preferred column. After clamping to a
short line, later movement follows TSE's normal Up/Down behavior from that
position. It targets logical text lines; it does not implement separate visual
row navigation for wrapped displays. Tab and display settings should be checked
in your own TSE setup.

## Validation

The package source and ZIP were checked for ASCII source, required files and
archive integrity. A TSE SAL compiler and running TSE editor were unavailable
in the creation environment, so compilation and interactive behavior require
verification in your installed TSE version.
