# SEARCHFILEEXECMACROINCLUDE

Version: **1.0.0.0.6**  
Date and time: **2026-09-25 19:56 CEST (Europe/Amsterdam)**  
SAL source author: **GPT-6 (OpenAI)**

## Description

Searches a specified SAL source file from top to bottom using TSE's `Find()` regular expression syntax. At an encountered `#INCLUDE [ "file" ]`, `#INCLUDE "file"`, `ExecMacro("name")`, `PROCMacroRunPurge("name")`, or `PROCMacroRunKeep("name")`, it searches the referenced source recursively, then resumes the referring file on its next line. A macro name without an extension refers to `name.s`; `.mac` is converted to `.s`. It ignores `//` comments and `/* ... */` comments, including block comments spanning several lines. A quoted `//` inside code remains text. For macro calls with arguments inside one quoted string, the first space-delimited token is treated as the macro filename. It does **not** execute referenced macros.

Results are collected in a separate TSE buffer as `filename(line,column): matching line`. Unresolved references and a summary are appended. During the search the editor keeps the original screen visible and puts each current filename in the message bar. When scanning finishes, every searched source is loaded into TSE's normal file ring and the complete results buffer is displayed. The original files are not modified.

## Installation and use

1. Extract the three files together. Keep `searchfileexecmacroinclude.ini` in TSE's current directory when running the macro.
2. Compile `searchfileexecmacroinclude.s` using your matching TSE SAL compiler (for example, `sc32 searchfileexecmacroinclude.s`).
3. Run the compiled macro from TSE's **Execute Macro** command.
4. Enter the TSE regular expression.
5. Enter search options, for example `ix`. The macro adds `x` if omitted. Options `a`, `b`, `g`, and `v` are rejected because they disrupt file and line order.
6. Enter the initial filename, such as `C:\temp\foobar.txt`.
7. At `Optional additional directories to search in (semi colon ';' separated):`, optionally enter directories separated by semicolons, for example `C:\TEMP1; C:\TEMP2; C:\TMP`. Leave blank if none.
8. Watch filenames in the message bar. When the search finishes, the results buffer appears on screen with all matches; every searched file remains loaded in TSE's file ring. Save the results buffer if you need a permanent report. Close it before running the macro again.

For relative references the lookup order is: directory containing the running compiled macro, directory containing the referring source file, supplied directories from left to right, then TSE's current directory and configured `TSEPath` (not the operating-system environment variable), and finally the editor directory returned by `LoadDir()`. For macro calls, TSE's `SearchPath(source, Query(TSEPath), "mac")` lookup also checks the `mac` subdirectory after each `TSEPath` directory and after `LoadDir()`. For includes, it uses `SearchPath(source, Query(TSEPath), ".")`. Absolute references use the stated path. The initial filename follows this same lookup.

## INI file

`[searchfileexecmacroinclude]` has `silent=false` by default. Set `silent=true` to suppress the introductory `Warn()` box. Error boxes remain visible.

## Limits

The parser handles one quoted reference of each kind per source line. Commented text is replaced with spaces while preserving search columns; broad regexes that match whitespace can therefore match those placeholder spaces. The search records the first match per line; very long lines are truncated to 255 characters in the report. Search patterns spanning multiple lines, dynamic filename expressions, and references inside comments or string literals are not parsed semantically. A visited-files buffer stops cycles and duplicate source scans; recursion is also limited to 24 levels. TSE searches the referenced `.s` source, so it must be available even when the compiled `.mac` exists. This version has not been compiled in the user's Windows TSE environment.
