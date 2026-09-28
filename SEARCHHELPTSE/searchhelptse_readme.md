# SEARCHHELPTSE

Version: 1.0.0.0.2  
Date and time: 2026-09-28 02:35 Europe/Amsterdam  
Author: GPT-6 (OpenAI)

SEARCHHELPTSE searches one or more text files on disk for a TSE search expression and shows matching lines in a read-only picklist. The package includes `tsehelp.s`, a text copy of TSE Professional's internal help screens. Press Enter on a result to open its source file at the matching line and column; press Escape to close the list. After opening a hit, press **Ctrl+Alt+H** to reopen the last results list without searching again. Keep the macro loaded in TSE so its key assignment remains active.

## Install and run

1. Extract all files to one directory. Keep `searchhelptse.s`, `searchhelptse.ini`, and `tsehelp.s` together.
2. From that directory, compile `searchhelptse.s` with your TSE SAL compiler, for example `sc32 searchhelptse.s`.
3. Run the compiled macro in TSE (or run the source through TSE's macro compilation facility).
4. Enter a search string, search options, and one or more disk filenames separated by semicolons. A configured full or relative path is checked as entered. For each relative entry (including a bare filename such as `tsehelp.s`), the macro also checks the directory of `CurrMacroFilename()` and TSE's current directory. A missing file produces an error message and stops the search.
5. Browse with arrow keys or SpeedSearch. Press Enter to open a hit, or Escape to exit.

## Configuration

Edit `searchhelptse.ini` to supply initial values for the three Ask prompts. Each prompt can still be changed when the macro runs:

```ini
[searchhelptse]
searchstring=
searchoptions=ix
searchlocations=tsehelp.s
silent=false
```

`i` ignores case and `x` enables TSE regular expressions. You can also use `w` for whole words, `^` for line starts, or `$` for line ends. Options that change the search scope or direction (`a`, `b`, `g`, `l`, `v`, `c`, `+`) are rejected because the macro controls the file traversal and its own picklist. `silent=false` shows the introductory Warn box; `silent=true` hides it. Errors may still show a Warn box.

Example file list: `tsehelp.s;C:\\docs\\other-help.txt`. Unreadable files are counted in a warning after the list closes. A result displays the source filename, line, column, and a preview (up to 160 characters). The full source file is opened when selected.

Each new search replaces the previous results. The macro does not modify the searched files.
