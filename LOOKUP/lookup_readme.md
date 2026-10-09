# LOOKUP

## Version information

- Version: 1.0.0.0.4
- Date: 2026-09-19
- Time: 11:01:53 UTC
- Original author: Chris Shuffett
- Documentation and package version prepared with: OpenAI Codex

## Description

LOOKUP is a TSE Pro/32 SAL macro that helps prevent typing mistakes while editing SAL source code. It displays searchable lists from which a command or procedure name can be selected and inserted at the current cursor position.

LOOKUP provides two lookup modes:

- **TSE command lookup** reads the supplied `tse.260` file and lists built-in TSE commands.
- **Local procedure lookup** scans the current SAL source buffer for procedures and menus and lists the names it finds.

The selected name is inserted with parentheses, for example `AddLine()` or `Main()`.

## Package contents

- `lookup.s` - LOOKUP SAL source code.
- `tse.260` - list of built-in TSE commands used by the F12 lookup.
- `file_id.diz` - original short package description.
- `lookup.ini` - initial configuration/reference file.
- `lookup_readme.md` - this documentation.

## Requirements

- TSE Pro/32 or a compatible 32-bit TSE release.
- The TSE SAL compiler appropriate for the installed editor.
- `lookup.s` compiled as `lookup.mac`.
- `lookup.s`, the compiled `lookup.mac`, and `tse.260` kept together in the same directory.

The original description identifies compatibility with TSE Pro/32 versions 2.6 through 4.0. Later TSE versions may also work, but should be tested.

## Installation

1. Extract all files from `lookup1.0.0.0.4.zip`.
2. Copy `lookup.s` to a working directory.
3. Compile it with the TSE SAL compiler:

   ```text
   sc32 lookup.s
   ```

4. Copy the resulting `lookup.mac` to a directory from which TSE loads macros.
5. Keep `lookup.s`, the resulting `lookup.mac`, and `tse.260` together in the same directory.
6. Load `lookup.mac` in TSE, either manually or through the normal autoload configuration.

## How to run LOOKUP

### Insert a built-in TSE command

1. Open a SAL source file in TSE.
2. Put the cursor where the command must be inserted.
3. Press `F12`.
4. Search or move through the **TSE Commands** list.
5. Select a command and press `Enter`.
6. LOOKUP inserts the selected command at the cursor position.

### Insert a local procedure name

1. Open the SAL source file containing the procedures to search.
2. Put the cursor where the procedure name must be inserted.
3. Press `Shift+F12`.
4. Search or move through the **Local Commands** list.
5. Select a procedure and press `Enter`.
6. LOOKUP inserts the selected procedure name at the cursor position.

Press `Esc` to close a selection list without inserting an item.

## Default keys

| Key | Action |
| --- | --- |
| `F12` | Show the built-in TSE command list from `tse.260`. |
| `Shift+F12` | Scan the current file and show its local procedures. |

## Search behavior

Both lists enable TSE's list-search facility. Start typing or use the normal TSE list-search commands to locate an entry, then press `Enter` to insert it.

The local lookup recognizes SAL declarations resembling menus, procedures, integer procedures, and string procedures. It scans only the current buffer.

## Configuration file

`lookup.ini` supplies the command-list filename used by `lookup.s`:

```ini
[lookup]
commandlist=tse.260
```

The configured file is resolved relative to the portable directory containing `lookup.mac`. If `commandlist=` is empty, omitted, or `lookup.ini` does not exist, LOOKUP falls back to `tse.260`.

The `F12` and `Shift+F12` hotkeys are SAL compile-time definitions and therefore are not runtime INI settings. Change their key-definition lines in `lookup.s` and recompile when different keys are required.

## Troubleshooting

### `Cannot find tse.260 in the lookup macro directory.`

This message means that LOOKUP could not find `tse.260` in the directory containing the running `lookup.mac`:

```text
SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + "tse.260"
```

Keep `lookup.s`, `lookup.mac`, and `tse.260` together, then try again.

### F12 or Shift+F12 starts another command

Another macro or UI definition may already use the key. Change the key definitions near the end of `lookup.s`, recompile the macro, and reload it.

### No local procedures are listed

- Make sure the current file contains SAL procedure declarations.
- Confirm that the declarations use syntax recognized by the macro's regular expression.
- The local lookup searches the current buffer only; it does not scan included or separately loaded source files.

### Changes to `tse.260` do not appear

The built-in command list is stored in a hidden buffer after its first successful use. Reload `lookup.mac` or restart TSE after changing `tse.260`.

## Notes and limitations

- LOOKUP searches for `tse.260` in the directory containing the running `lookup.mac`; it does not depend on `LoadDir()`.
- Local procedure lookup is limited to the current SAL source buffer.
- Names are inserted with `()` but no parameters are supplied.
- The maximum stored command or procedure text is limited by the macro's 32-character string.
- `lookup.ini` actively controls the command-list filename.
- Hotkeys remain compile-time settings in `lookup.s`.

## Version history

### 1.0.0.0.4 - 2026-09-19 11:01:53 UTC

- Added active reading of `commandlist=` from portable `lookup.ini`.
- Resolves the configured command-list file relative to `lookup.mac`.
- Uses `tse.260` when the INI file or value is missing or empty.
- Removed the misleading `builtin_key=` and `local_key=` entries because SAL key bindings are compiled into the macro.
- Updated the documentation to distinguish runtime configuration from compile-time hotkeys.

### 1.0.0.0.3 - 2026-09-18 23:31:56 UTC

- Added a `FileExists()` check before calling `EditFile()`.
- Prevents `EditFile()` from silently creating an empty `tse.260` buffer.
- Searches for `tse.260` in the portable LOOKUP directory containing `lookup.s` and `lookup.mac`.
- Removed the dependency on the TSE `LoadDir()` location.
- Shows a clear warning when the command-list file cannot be found.

### 1.0.0.0.2 - 2026-09-18 23:28:37 UTC

- Removed the hidden `[procs]` buffer used for the built-in command list.
- The `F12` lookup now displays `tse.260` directly with `lList()`.
- Preserves `tse.260` when it was already loaded before LOOKUP started.
- Removed the version 1.0.0.0.1 `KillLine()` workaround.
- Fixes the one-line blank **TSE Commands** list seen with TSE 4.50.

### 1.0.0.0.1 - 2026-09-18 23:24:29 UTC

- Removed the empty one-item wrapper menus.
- Changed `F12` and `Shift+F12` to call the actual lookup procedures directly.
- Removed the unreliable `PushKey(<Enter>)` menu activation method.
- Removed the initial blank line from both generated command lists.
- Replaced the misleading LAN error with the actual missing `tse.260` path.

### 1.0.0.0.0 - 2026-09-18 23:18:35 UTC

- Added complete Markdown description, help, installation, and run instructions.
- Added `lookup.ini` as the initial configuration/reference file.
- Repackaged the original LOOKUP files with the new documentation.
