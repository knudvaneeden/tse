# SEARCHFILEEXECMACROINCLUDE

Version: **1.0.0.0.11**  
Date and time: **2026-09-28 12:58 CEST (Europe/Amsterdam)**  
SAL source author: **GPT-6 (OpenAI)**

## Description

Searches a specified SAL source file from top to bottom using TSE's `Find()` regular expression syntax. At an encountered `#INCLUDE [ "file" ]`, `#INCLUDE "file"`, `ExecMacro("name")`, `PROCMacroRunPurge("name")`, or `PROCMacroRunKeep("name")`, it searches the referenced source recursively, then resumes the referring file on its next line. A macro name without an extension refers to `name.s`; `.mac` is converted to `.s`. It ignores `//` comments and `/* ... */` comments, including block comments spanning several lines. A quoted `//` inside code remains text. For macro calls with arguments inside one quoted string, the first space-delimited token is treated as the macro filename. It does **not** execute referenced macros.

Results are collected in a TSE `List()` picker as `filename (line,column): matching line`. During the search the editor keeps the original screen visible, hides the moving cursor, and puts each current filename in the message bar. Its previous cursor visibility is restored when the search finishes. When scanning finishes, every searched source is loaded into TSE's normal file ring; a queued key opens the results list after the search command returns to TSE's main loop. Press **Enter** on a hit to open its file at the matching line and column. Press **Ctrl+Alt+Shift+H** to reopen the same results list. The original files are not modified.

## Installation and use

1. Extract the three files together. Keep `searchfileexecmacroinclude.ini` in TSE's current directory when running the macro.
2. Compile `searchfileexecmacroinclude.s` using your matching TSE SAL compiler (for example, `sc32 searchfileexecmacroinclude.s`).
3. Run the compiled macro from TSE's **Execute Macro** command.
4. Enter the TSE regular expression.
5. Enter search options, for example `ix`. The macro adds `x` if omitted. Options `a`, `b`, `g`, and `v` are rejected because they disrupt file and line order.
6. Enter the initial filename, such as `C:\temp\foobar.txt`.
7. At `Optional additional directories to search in (semi colon ';' separated):`, optionally enter directories separated by semicolons, for example `C:\TEMP1; C:\TEMP2; C:\TMP`. Leave blank if none.
8. Watch filenames in the message bar. When the search finishes, the results list appears; every searched file remains loaded in TSE's file ring. Select a hit and press **Enter** to open its exact location. Press **Ctrl+Alt+Shift+H** to return to the list. **Esc** closes the list.
9. Running the still-loaded macro again reopens the list. To start a fresh search, run it with MacroCmdLine `new` (for example, `ExecMacro("searchfileexecmacroinclude new")`). Keep the macro loaded if you want its return key to keep working; a purge wrapper removes its saved results and key binding. This key is also used by SEARCHHELPTSE, so the last enabled binding takes precedence.

For relative references the lookup order is: directory containing the running compiled macro, directory containing the referring source file, supplied directories from left to right, then TSE's current directory and configured `TSEPath` (not the operating-system environment variable), and finally the editor directory returned by `LoadDir()`. For macro calls, TSE's `SearchPath(source, Query(TSEPath), "mac")` lookup also checks the `mac` subdirectory after each `TSEPath` directory and after `LoadDir()`. For includes, it uses `SearchPath(source, Query(TSEPath), ".")`. Absolute references use the stated path. The initial filename follows this same lookup.

## INI file

`[searchfileexecmacroinclude]` has `silent=false` by default. Set `silent=true` to suppress the introductory `Warn()` box. Error boxes remain visible.

`[SearchDefaults]` contains four optional initial values for the prompts. All are blank by default:

```ini
[SearchDefaults]
searchstring=
searchoptions=
searchfilename=
additionaldirectories=
```

Fill in any values to prepopulate the corresponding `Ask()` prompts. Text the user enters or changes in a prompt takes priority for that run. `additionaldirectories` uses semicolons as separators. An empty `searchoptions` is allowed: the macro adds the regular expression option `x` when running.

## Limits

The parser handles one quoted reference of each kind per source line. Commented text is replaced with spaces while preserving search columns; broad regexes that match whitespace can therefore match those placeholder spaces. The list contains each occurrence found by `Find()`; very long lines are truncated to 255 characters in the preview. Search patterns spanning multiple lines, dynamic filename expressions, and references inside comments or string literals are not parsed semantically. A visited-files buffer stops cycles and duplicate source scans; recursion is also limited to 24 levels. TSE searches the referenced `.s` source, so it must be available even when the compiled `.mac` exists. This version has not been compiled in the user's Windows TSE environment.
