# KEYASSIG — Keyboard Assignment Help for TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-13 19:47:23 UTC  
**Session:** Create KEYASSIG MarkDown Readme

## Description

KEYASSIG is a package of two TSE SAL macros that inspect the keyboard assignments defined in the TSE user-interface file:

- `KEYASSGN.S` displays the command assigned to a key that you press.
- `KEYFIND.S` searches the keyboard definitions for keys, commands, comments, or other text.

Both macros read the configured TSE UI source file. In the supplied source, that file is:

```text
ui\tse.ui
```

The package was originally written by Dieter Koessl and donated to the public domain. The included source history identifies `KEYASSGN.S` and `KEYFIND.S` as version 3.01 dated 1997-04-18.

## Package Contents

| File | Purpose |
|---|---|
| `KEYASSGN.S` | Shows the command and description assigned to a pressed key |
| `KEYFIND.S` | Searches and lists matching key assignments |
| `KEYTABLE.SI` | Key-code table used by the non-Win32 build |
| `READ.ME` | Original documentation |
| `FILE_ID.DIZ` | Short package description |

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- Access to the UI source file containing the active key definitions.
- By default, the macros expect `tse.ui` in the `ui` directory below the TSE installation directory.

For a current 32-bit TSE installation, compile the two `.S` files with the corresponding `sc32.exe` compiler.

## Installation

1. Extract `keyassig.zip` into a working directory.
2. Confirm that the UI source file exists at the location expected by both macros.
3. If your UI filename or directory differs, edit these declarations near the top of both `KEYASSGN.S` and `KEYFIND.S`:

   ```sal
   string cmd_path[] = "ui\"
   string cmd_file[] = "tse.ui"
   ```

4. Keep the trailing backslash in `cmd_path`.
5. Compile the macros:

   ```bat
   sc32 KEYASSGN.S
   sc32 KEYFIND.S
   ```

6. Copy the resulting `KEYASSGN.MAC` and `KEYFIND.MAC` files to a directory from which TSE can load macros.

## How to Run KEYASSGN

1. Start TSE.
2. Execute the macro `KEYASSGN` using TSE's macro execution command.
3. At the prompt, press the key or key combination you want to inspect.
4. The popup displays:

   - the recognized key name;
   - the assigned TSE command;
   - the comment or description found in the UI definition, when present.

5. For a two-key assignment, press the first key and then the second key when prompted.
6. Press `Escape` to close the popup and unload the macro.

If no definition is found, the macro reports `not assigned`. If the matching line does not have a valid key-definition format, it reports `invalid keydefinition`.

## How to Run KEYFIND

1. Start TSE.
2. Execute the macro `KEYFIND`.
3. Enter one or more search strings. Separate multiple strings with commas.
4. Enter `all` to list the entire key-assignment file.
5. Press `Enter` to display the matching assignments.
6. In the results list, use:

   - `Alt-K` to sort by key;
   - `Alt-C` to sort by command;
   - `Enter` to search within the displayed list;
   - `Escape` to close the list.

The search is case-insensitive and uses the TSE regular-expression search supported by the macro.

## Optional Help Menu Entries

The original documentation suggests adding the following entries to the `HelpMenu()` definition in the UI source:

```sal
"&Find Key...",             ExecMacro("keyfind")
"&Display Assignments...",  ExecMacro("keyassgn")
```

After changing the UI source, reinstall or recompile the UI according to the procedure for your TSE installation.

## Troubleshooting

### Cannot load UI file

Check `cmd_path` and `cmd_file` in both macro sources. The supplied code constructs the UI filename relative to TSE's load directory. Confirm that the target file exists and that `cmd_path` ends with a backslash.

### Cannot find UI file

`KEYFIND` could not open the configured UI source. Correct the path declarations and recompile the macro.

### Cannot allocate key table or work buffer

TSE could not create a temporary buffer or load the key table. Close unnecessary files or applications and try again.

### Results do not match the active keys

Make sure the macros read the same UI source from which the currently installed TSE interface was built. If you changed the UI file, reinstall the UI and restart TSE if necessary.

### A key is reported as not assigned

The key may genuinely be unassigned, or its definition may be located in another included UI source file that is not present as searchable text in the configured `tse.ui` file.

## Version History

### 1.0.0.0.0 — 2026-09-13 19:47:23 UTC

- Created the Markdown description and help file.
- Documented package contents, requirements, compilation, installation, and operation.
- Documented both `KEYASSGN` and `KEYFIND`.
- Added UI configuration, optional Help menu entries, keyboard controls, and troubleshooting information.

Future documentation revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Copyright and Disclaimer

According to the original `READ.ME`, the program was donated to the public domain and may be used or altered at the user's own risk.
