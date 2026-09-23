# NEWBOOKS

Package version: **1.0.0.0.1**  
Prepared: **2026-09-23 21:12:12 UTC**  
Original macro: James Coffer, September 9, 1995, version 3.00. The original copyright and noncommercial redistribution notice remain in `NEWBOOKS.S`. Package changes: OpenAI Codex (GPT-6).

## Description

NEWBOOKS manages TSE bookmarks identified by letters A through Z. It displays a list showing each bookmark's letter, filename, line number, and text. Select an entry to jump to its bookmark; you can also place, cycle through, and remove bookmarks with the keys below.

The updated `Main()` reads `newbooks.ini`, optionally displays an introductory `Warn()` box, then opens the bookmark list. The original key assignments remain available after the macro is loaded.

## Package contents

- `NEWBOOKS.S` — editable TSE SAL source, updated for this package.
- `NEWBOOKS.MAC` — original 1995 compiled macro from the supplied archive; **compile `NEWBOOKS.S` to get the new startup and INI behavior**.
- `newbooks.ini` — introductory message setting.
- `newbooks_readme.md` — this guide.
- `FILE_ID.DIZ` — original archive description.

## Install and run

1. Extract the ZIP into a directory of your choice.
2. Copy `newbooks.ini` into the directory returned by TSE's `Query(StartUpPath)` (normally the directory that was current when TSE started). The updated source reads the INI there; it does not require `LoadDir()`.
3. Compile `NEWBOOKS.S` using your TSE SAL compiler, for example `sc32 NEWBOOKS.S`. This produces an updated `NEWBOOKS.MAC`, replacing the original compiled macro in your working directory.
4. Load or execute the newly compiled `NEWBOOKS.MAC` in TSE. Running it invokes `Main()`: dismiss the introductory message if shown, then use the bookmark list. If there are no bookmarks yet, press Esc, place one with Ctrl+Q, then open the list with Alt+B.

No compiler is included in the package. Compilation and runtime behavior have not been tested in a TSE installation here.

## Keys

| Key | Action |
| --- | --- |
| Alt+B or Ctrl+F | Open the bookmark list. |
| Ctrl+Q | Place the next available bookmark at the current location. |
| Ctrl+E | Cycle to another bookmark. |
| Enter in list | Go to the selected bookmark. |
| Del in list | Delete the selected bookmark after confirmation. |
| Space in list | Mark or unmark a list entry for bulk deletion. |
| F7 in list | Delete marked bookmarks after two confirmations. |
| F1 in list | Open the macro's built-in help. |
| Esc in list | Close the list. |

The list also supports arrow keys, Home, End, PgUp, and PgDn. The source binds Ctrl+Shift+Z to display the original author credit.

## Configuration

In `newbooks.ini`:

```ini
[newbooks]
silent=false
```

With `silent=false` (the default), `Main()` shows the introductory `Warn()` box. Set `silent=true` to skip that box and open the bookmark list immediately. A missing INI or missing key defaults to `false`. This setting affects the introductory box, not the existing bookmark commands or confirmation prompts.

## Change history

- **1.0.0.0.1** (2026-09-23): Removed the obsolete `AttrSet` / `_COLOR_` selection that prevented compilation with SAL Compiler V4.50.rc23 for Win32. The bookmark list now sets its cursor attribute directly. Compilation still needs confirmation in TSE.

- **1.0.0.0.0** (2026-09-23): Added the README, INI setting, and `Main()` startup message followed by the bookmark list. Retained the original source credit and original compiled macro.
