# NEWSRCH

Version: **1.0.0.0.0**  
Prepared: **2026-09-24 23:02 UTC**  
Original macro: Buddy E. Ray Asbury, Jr. (1994); modifications by Stuart Warren.

NEWSRCH searches or replaces text across files **currently open in TSE**. It collects matches in a hidden buffer and presents a picklist. A result takes you to the matching file, line, and column. Replace changes text in the open buffers; save the affected files when satisfied.

## Files

- `NEWSRCH.S`: SAL source, with a startup menu and configurable startup message.
- `newsrch.ini`: startup message setting.

## Install and run

1. Extract both files into your working directory. Keep `newsrch.ini` in the current directory when launching TSE.
2. Compile `NEWSRCH.S` with your compatible TSE SAL compiler, for example `sc32 NEWSRCH.S`. This produces `NEWSRCH.MAC`.
3. Load or execute `NEWSRCH.MAC` in TSE. Its `Main()` displays an explanation and opens the **Multi-File Find/Replace** menu.
4. Choose **Find** or **Replace**, enter the target (and replacement if applicable), and enter search options. The default is `I` (ignore case); `W` matches whole words and `X` enables regular expressions. Inspect the picklist and select a result to visit it.
5. Use the menu's **Picklist**, **Next**, and **Previous** actions to revisit results. Save changed files after a replacement.

The macro's existing key bindings use `Alt+V` followed by `v` for the menu, `f` for Find, `r` for Replace, `a` for Picklist, `n` for Next, and `p` for Previous. Shifted letters are also bound. These bindings may conflict with other TSE assignments.

## Configuration

`newsrch.ini` contains:

```ini
[newsrch]
silent=false
```

With `silent=false` (the default), running the macro displays its informative `Warn()` box before the menu. Set `silent=true` to open the menu without that box. The source reads the INI by its filename from the current directory; an absent setting defaults to `false`.

## Notes

- The macro searches files already loaded in the editor; it does not scan a directory on disk.
- Replacement modifies open buffers. Review and save them deliberately.
- The original source is from 1994. Compile and test with your TSE version; a SAL compiler is not available in this package-building environment.
