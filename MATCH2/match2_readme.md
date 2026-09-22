# MATCH2

Version: 1.0.0.0.13  
Date and time: 2026-09-22 00:14:31 UTC  
Updated with: OpenAI Codex

## Description

MATCH2 is a TSE SAL macro that moves the cursor between matching TSE SAL control statements. It supports `if`/`else`/`elseif`/`endif`, `case`/`when`/`otherwise`/`endcase`, `while`/`endwhile`, `for`/`endfor`, `loop`/`endloop`, `do`/`enddo`, and `repeat`/`until`.

When the cursor is not on a supported control word, MATCH2 uses an embedded version of the standard SemWare `MATCH.S` behavior. It matches parentheses, square brackets, braces, and angle brackets. On a single or double quote, it reports the number of characters up to the corresponding quote.

The original matching procedure is `mLanguageMatch()`. Running the compiled macro directly calls `Main()` and displays a short usage message.

## Requirements

- The SemWare Editor (TSE) and its SAL compiler.
- A TSE version providing the built-in `GetWord()` function.
- A source file for which TSE language handling is active.

## Files

- `match2.s` - TSE SAL source code.
- `match2.ini` - configuration file for startup-warning behavior.
- `match2_readme.md` - this description and help file.

## Compile

1. Extract all files from `match21.0.0.0.13.zip` into one directory.
2. Open a command prompt in that directory.
3. Compile the source with:

   ```text
   sc32 match2.s
   ```

4. Confirm that the compiler creates `match2.mac` without errors.

## Install and assign a key

1. Load `match2.mac` in TSE using your normal macro-loading method.
2. MATCH2 enables its `Match2Keys` key definition when the macro loads.
3. The procedure `mLanguageMatch()` is assigned to `<Alt F3>`.
4. Make sure `<Alt F3>` is not overridden by another active key definition.

## How to run

1. Open a supported source file in TSE.
2. Put the cursor on a supported language control word, for example `if`, `endif`, `while`, `end`, `case`, or `otherwise`.
3. Press `<Alt F3>`.
4. MATCH2 moves the cursor to the corresponding control statement.

For ordinary brackets, put the cursor on the character and press the same key. MATCH2 then uses its embedded standard matching behavior.

Running `match2.mac` directly executes `Main()` and displays an informative message. The matching feature itself is run through the key assigned to `mLanguageMatch()`.

## Configuration

Keep `match2.ini` in the same directory as the compiled MATCH2 macro. The initial setting is:

```ini
[match2]
silent=false
```

- `silent=false` displays the informative startup warning when MATCH2 is run directly.
- `silent=true` suppresses the startup warning.
- If `match2.ini` is missing or the value is invalid, MATCH2 uses `silent=false`.

## Notes

- MATCH2 is intended for TSE SAL source code. Words inherited from the old xBase or Clipper implementation are not part of the advertised supported feature set.
- Nested control structures are counted while MATCH2 searches upward or downward.
- Intermediate words such as `else` and `elseif` are handled as surrounding matches.
- `while` and `endwhile` are matched as an exact pair. Nested `while` blocks are counted, and an unrelated `end` is ignored.
- `for`/`endfor`, `loop`/`endloop`, `do`/`enddo`, and `repeat`/`until` are exact, nesting-aware pairs.
- The dedicated TSE SAL control-structure pairs take priority over inherited generic matching. Plain `do` is therefore matched with `enddo`.
- Repeatedly pressing `<Alt F3>` navigates `case` -> `when` -> subsequent `when` -> `otherwise` -> `endcase`.
- Nested `case` blocks are skipped while navigating the keywords of the current `case` block.
- On `endcase`, `<Alt F3>` moves backward to its matching `case`.
- TSE SAL syntax is case-insensitive. MATCH2 also normalizes text returned by `GetWord()` with `Lower()` before comparing runtime strings, so uppercase and lowercase source keywords are supported.
- Save and back up important work before testing any newly compiled macro.

## Version history

### 1.0.0.0.13 - 2026-09-22 00:14:31 UTC

- Added the `silent` setting to `match2.ini` with the initial value `silent=false`.
- Added portable loading of `match2.ini` from the MATCH2 macro directory.
- `silent=true` suppresses the direct-run startup warning; `silent=false`, a missing INI file, or an invalid value shows it.
- Updated the package version, source header, direct-run message, INI file, and documentation.

### 1.0.0.0.12 - 2026-09-21 23:48:49 UTC

- Added a multiline `if`/`elseif`/`else`/`endif` control structure to the complete TSE SAL example.
- Defined MATCH2's advertised scope as TSE SAL and documented that its dedicated TSE SAL matching takes priority over inherited generic behavior.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.11 - 2026-09-21 23:41:42 UTC

- Changed the active MATCH2 key assignment from `<Ctrl F12>` to `<Alt F3>`.
- Updated the direct-run message, installation instructions, usage steps, CASE navigation help, and example instructions.
- Updated the package version, source header, INI file, and documentation.

### 1.0.0.0.10 - 2026-09-21 23:31:50 UTC

- Added a complete TSE SAL example covering every recently supported control structure.
- Included bracket-pair examples for the standard matching fallback.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.9 - 2026-09-21 23:19:43 UTC

- Added exact bidirectional matching for `for`/`endfor`.
- Added exact bidirectional matching for `loop`/`endloop`.
- Added exact bidirectional matching for `do`/`enddo`.
- Added exact bidirectional matching for `repeat`/`until`.
- Each new pair counts nested blocks of the same type and ignores unrelated closing words.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.8 - 2026-09-21 23:05:52 UTC

- Changed CASE navigation to visit every same-level branch keyword in order.
- The sequence is `case` -> `when` -> subsequent `when` -> `otherwise` -> `endcase`.
- Nested `case` blocks are skipped when looking for the next keyword of the current block.
- Kept reverse navigation from `endcase` to its matching `case`.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.7 - 2026-09-21 23:00:58 UTC

- Normalized words returned by `GetWord()` with `Lower()` before runtime string comparisons.
- Fixed matching when source keywords are written as uppercase `CASE`, `WHEN`, `OTHERWISE`, and `ENDCASE`.
- Kept the distinction between TSE SAL's case-insensitive syntax and the spelling preserved in extracted source text.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.6 - 2026-09-21 22:55:52 UTC

- Added exact, nesting-aware matching between `case` and `endcase`.
- Added forward matching from `when` and `otherwise` to the corresponding `endcase`.
- Generalized the exact pair matcher for both `while`/`endwhile` and `case`/`endcase`.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.5 - 2026-09-21 22:46:46 UTC

- Assigned `mLanguageMatch()` to `<Ctrl F12>` through the enabled `Match2Keys` key definition.
- Added exact, nesting-aware matching between `while` and `endwhile`.
- Prevented a `while` search from incorrectly stopping at an unrelated plain `end`.
- Added `endwhile` to the recognized closing control words.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.4 - 2026-09-21 22:32:39 UTC

- Replaced the unavailable historical `mMatch()` helper with a self-contained implementation based on SemWare's standard `MATCH.S` behavior.
- Preserved nested matching for `()`, `{}`, `[]`, and `<>`, forward lookup of a match character, and quoted-string length reporting.
- Removed the final runtime dependency on historical `TSE.S` helper procedures without assuming that `mMatch()` was built in.
- Corrected compiler error 2335, `Undefined symbol 'mMatch' encountered`.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.3 - 2026-09-21 22:29:14 UTC

- Removed the obsolete `language` and `cmode` global-variable check inherited from the historical `TSE.S` environment.
- `mLanguageMatch()` now tries the language-word match directly and falls back to `mMatch()` when no supported word match is found.
- Corrected compiler error 2335, `Undefined symbol 'language' encountered`.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.2 - 2026-09-21 22:26:44 UTC

- Replaced the unavailable `GetFirstWord()` helper with the self-contained `FNGetFirstWord()` procedure.
- The replacement preserves the cursor position and returns the space-padded first word expected by the original matching logic.
- Corrected compiler error 2335, `Undefined symbol 'GetFirstWord' encountered`.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.1 - 2026-09-21 22:24:11 UTC

- Replaced both obsolete `GetWordAtCursor()` calls with TSE's built-in `GetWord()` function.
- Corrected compiler error 2335, `Undefined symbol 'getWordAtCursor' encountered`.
- Updated the package version, source header, INI file, direct-run message, and documentation.

### 1.0.0.0.0 - 2026-09-21 21:34:20 UTC

- Packaged the legacy MATCH source as MATCH2.
- Added this Markdown description, help, compilation, installation, and usage guide.
- Added `match2.ini` as a reserved configuration file.
- Added `Main()` with an informative message for direct execution.
- Preserved the original `mLanguageMatch()` matching behavior and its fallback to `mMatch()`.

## Complete TSE SAL example

Place the cursor on each control word or bracket and press `<Alt F3>` to test MATCH2.

```sal
PROC Main()
 INTEGER I = 0
 CASE I
  WHEN 1
  WHEN 2
 OTHERWISE
 ENDCASE

FOR I = 1 TO 10
ENDFOR

I = 0
IF I == 1
 ELSEIF I == 2
 ELSEIF I == 3
ELSE
ENDIF

I = 0
LOOP
 I = I + 1
 IF I > 10 BREAK ENDIF
ENDLOOP

I = 0
WHILE I < 10
 I = I + 1
ENDWHILE

DO 5 TIMES
ENDDO

I = 0
REPEAT
 I = I + 1
UNTIL I > 10

// { ( [ ] ) }

END
```
