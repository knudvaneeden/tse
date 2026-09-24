# NEXTPUNC

Version: **1.0.0.0.0**  
Created: **2026-09-24 23:38 UTC**  
Package notes: **GPT-6**

## Description

NEXTPUNC moves the cursor forward on the current line to the first character after the next period (`.`), comma (`,`), exclamation mark (`!`), colon (`:`), semicolon (`;`), or question mark (`?`). It skips spaces and tabs after the punctuation. The character it reaches need not be a word character. The search starts one character to the right of the current cursor position.

If none of those punctuation marks remains on the line, the original macro sounds an alarm and stops. It does not search another line. Punctuation inside quoted text or comments is treated the same as other punctuation.

## Files

| File | Purpose |
| --- | --- |
| `nextpunc.s` | SAL source and `<Alt GreyCursorRight>` key assignment |
| `nextpunc.ini` | Controls the startup information box |
| `nextpunc_readme.md` | This help file |

## Compile and run

1. Extract all files into one directory and make it the current directory before starting TSE or running the macro.
2. Compile `nextpunc.s` with your TSE SAL compiler, for example `sc32 nextpunc.s`. This produces `nextpunc.mac`.
3. In TSE, execute `nextpunc.mac` as a macro. Its `Main()` displays the information box and performs one jump. If no later punctuation is present on the current line, it sounds an alarm.
4. To use the shortcut, load the compiled macro into TSE and press **Alt+GreyCursorRight** (Alt with the numeric keypad's right arrow). This runs `mNextPunc()` directly and moves once per keypress. If your TSE setup already assigns that key, change the assignment in the source and recompile.

## Configuration

Keep `nextpunc.ini` in the current working directory used by TSE when the macro runs:

```ini
[nextpunc]
silent=false
```

The default `silent=false` displays the information `Warn()` box when `Main()` runs. Set `silent=true` to suppress that box; navigation still runs. A missing INI file or missing setting also defaults to `false`. The shortcut calls `mNextPunc()` directly, so it does not show this introductory box on every keypress.

## Example

With the cursor before `Hello,   world!`, one jump stops at `w` in `world`. A further jump starts searching to the right of `w`.

## Version history

- **1.0.0.0.0** (2026-09-24 23:38 UTC): Added `Main()`, configurable introductory message, INI file, and documentation to the supplied 2009 macro.
