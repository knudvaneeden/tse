# NAMECLIP

Version: 1.0.0.0.3  
Package date and time: 2026-09-23 20:14:42 UTC  
Original macro: TSE Named Clipboard System by David Marcus, 1993 (the included `FILE_ID.DIZ` identifies the original release as 5.0.1).

## Description

NAMECLIP adds named clipboards to The SemWare Editor (TSE). It provides menus for copying, cutting, pasting, viewing and editing named clips. It can rename, delete, print and search clips, and save or restore the collection from a file. The original macro also includes paste-over and cut-with-blank-fill operations and settings for naming, backups and paste behavior.

This package adds a startup help message and an INI setting to control that message. The original clipboard operation bindings remain in the source.

## Install and run

1. Extract all files from `nameclip1.0.0.0.3.zip`.
2. Put `nameclip.ini` in TSE's startup directory (the directory returned by `Query(StartUpPath)`). Edit its `silent` setting if desired.
3. Compile `NAMECLIP.S` using the TSE SAL compiler, for example `sc32 NAMECLIP.S` with TSE for Windows 32-bit. This generates `NAMECLIP.MAC` if compilation succeeds.
4. Load `NAMECLIP.MAC` in TSE using its macro loading command, then execute NAMECLIP to show the startup help message. The macro's key bindings are available while loaded.
5. Press F11 for the main clipboard menu. Mark text and choose Copy or Cut, then choose Paste where needed. The menu exposes the other operations and settings.

The supplied 1993 source uses legacy TSE functions and character encoding. Compilation and runtime behavior on TSE 4.50 have not been verified here; if your compiler reports errors, retain its line number and message when requesting a compatibility fix.

## Keys

| Key | Action |
| --- | --- |
| F11 | Main clipboard menu |
| Ctrl+F11 | Other functions: view/edit, print, rename, delete and search |
| Shift+F11 | Clipboard settings |
| Alt+F11 | Global actions: load/save clips, delete all clips |
| Numeric keypad `*` | Paste append |
| Ctrl+numeric keypad `*` or Ctrl+Print Screen | Paste overwrite |
| Numeric keypad `+` / Ctrl+numeric keypad `+` | Copy overwrite / append |
| Numeric keypad `-` / Ctrl+numeric keypad `-` | Cut overwrite / append |
| Alt+numeric keypad `-` | Cut and fill with blanks |

TSE key names in the source use `<Grey*>`, `<Grey+>` and `<Grey->` for the numeric keypad keys. Check for conflicts with existing key assignments before relying on these shortcuts.

## Configuration

`nameclip.ini` contains:

```ini
[nameclip]
silent=false
```

`silent=false` (the default) displays the startup `Warn()` box when NAMECLIP is executed. `silent=true` suppresses only that startup box. Other warnings, menus and prompts still work normally. The value is read each time `Main()` runs, so edit the INI and execute NAMECLIP again to apply it. If the INI is missing, the default is `false`.

## Files

- `NAMECLIP.S`: SAL source with the new `Main()`.
- `nameclip.ini`: startup message setting.
- `nameclip_readme.md`: this help file.
- `FILE_ID.DIZ`: original archive description.

## Version history

- 1.0.0.0.3 (2026-09-23): Use `_EDIT_HISTORY_` for NAMECLIP name prompts and history entries; retains the clipboard ID replacements and startup help.
