# PRGNAV

**Version:** 1.0.0.0.1  
**Date and time:** 2026-09-27 16:51 CEST (14:51 UTC)  
**Documentation:** OpenAI GPT-6  
**Original navigation procedure:** Volker Multhopp (1993)

## Description

`VMPRGNAV.S` navigates up and down between lines according to their indentation. It is useful for code and outlines that use indentation to show structure. The navigation routine `vmProgNav()` returns 1 when navigation proceeds and 0 when it cannot proceed. It ignores empty lines while seeking a target. Its behavior depends on the indentation of the starting line and nearby lines; it can seek an equal or less indented line, such as `else` or `if` when starting at `endif`.

## Files

- `VMPRGNAV.S`: original navigation routine and key bindings, plus package startup help.
- `prgnav.ini`: controls the startup warning.
- `prgnav_readme.md`: this guide.

## Compile and run

1. Extract all files together into a directory.
2. From a command prompt in that directory, compile with the SAL compiler for your installed TSE version: `sc32 VMPRGNAV.S` (Win32 example).
3. Load or execute the resulting `VMPRGNAV.mac` in TSE. Keep `prgnav.ini` in TSE's **current working directory** when loading the macro.
4. Press **Alt+CursorUp** to navigate upward; press **Alt+CursorDown** to navigate downward. These are the bindings in version 1.0.0.0.1. Depending on keyboard or TSE configuration, you may need to change them and recompile.

## Configuration

```ini
[Settings]
silent=false
```

With `silent=false` (the default), `Main()` displays a `Warn()` box describing the keys when the macro runs. Set `silent=true` to skip that box. If the INI is missing, the warning remains enabled. This setting does not change navigation behavior.

## Navigation details

- Starting on a blank line: move in the chosen direction to a nonblank line.
- Starting at column 1: seek an indented line.
- Starting on an indented line: seek toward a line at an equal or higher structural level, using the indentation of the next nonblank line.
- Indentation must reflect the structure of the document for the jumps to be useful.
- The routine does not parse programming language syntax; cursor column is not used to decide the logical level.

## Notes

The original navigation routine has been retained; the key bindings were changed from Alt+GreyCursorUp/Down to Alt+CursorUp/Down. There is no bundled compiled `.mac`; compile the supplied source for your own TSE version. This package was inspected but could not be compiled here because `sc32` is unavailable in this environment.
