# CUAWS 5.7 for TSE Pro/32

**README version:** 1.0.0.0.0  
**CUAWS release:** 5.7  
**Created:** 2026-09-04 19:44:51 CEST (+0200)  
**Original CUAWS release date:** 2004-03-10  
**Original author:** Bill Stewart

## Description

CUAWS (CUA/WordStar) provides a WordStar-compatible user interface and an enhanced CUA-style block-marking macro for The SemWare Editor Professional (TSE Pro/32).

The package contains two components that can be installed together or used independently:

- `WORDSTAR.UI` — a WordStar-compatible TSE Pro/32 user interface with features beyond the standard user interfaces supplied with the editor.
- `CUA.S` — an enhanced CUA-style block-marking macro with keyboard, mouse, prompt-box, persistent-block, and Windows Clipboard support. It replaces the older `CUAMARK.S` macro.

## System requirements

- `WORDSTAR.UI` requires TSE Pro/32 4.2 or later and works with the console and GUI editions.
- `CUA.S` requires TSE Pro/32 2.6 or later.
- The TSE SAL compiler `sc32.exe` is required to compile the files.
- Windows Clipboard commands require a compatible Windows version of TSE.

## Archive contents

| File | Purpose |
|---|---|
| `WORDSTAR.UI` | WordStar-compatible TSE user interface |
| `CUA.S` | Enhanced CUA-style block-marking macro |
| `CUAWS.TXT` | Original installation guide and detailed User's Guide supplement |
| `HISTORY.TXT` | CUAWS release history |
| `WSDIFF.TXT` | Notes about WordStar command differences |
| `BURNIN.BAT` | Example batch file for compiling `WORDSTAR.UI` with `sc32.exe` |
| `FILE_ID.DIZ` | Short package description |

## Installation

### Install the WordStar user interface

1. Extract `cuaws57.zip` to a temporary directory.
2. Make a backup copy of your current TSE configuration and user-interface files.
3. Copy `WORDSTAR.UI` to the directory in which you keep TSE user-interface files, for example `C:\TSEPRO\UI`.
4. Open `WORDSTAR.UI` in TSE.
5. Run TSE's **Compile** command, normally by pressing **Ctrl+F9**.
6. Close and restart TSE. The compiled WordStar interface should then be active.

You may alternatively edit `BURNIN.BAT`, set `EDIR` to the directory containing `sc32.exe`, and run the batch file from a command prompt. Do not add a trailing backslash or surround the value assigned to `EDIR` with quotes. The batch file itself adds quotes when invoking the compiler, so a path containing spaces is supported.

Example:

```bat
set EDIR=C:\TSEPRO
BURNIN.BAT
```

### Install the CUA block-marking macro

1. Copy `CUA.S` to the directory in which you keep TSE SAL macro sources, for example `C:\TSEPRO\MAC`.
2. Open `CUA.S` in TSE.
3. Run the **Compile** command, normally **Ctrl+F9**. This creates `CUA.MAC`.
4. Load or execute `CUA.MAC` in TSE.

`WORDSTAR.UI` attempts to load `CUA.MAC` automatically at startup. It does not report an error when the macro is absent. When both components are installed, the CUA settings are available from the submenu at the bottom of the **Block** menu.

## Running and configuring CUA.S

Run the compiled macro with the following syntax:

```text
cua [on | off] [-t[+|-] -p[+|-]] [-c]
```

| Argument | Action |
|---|---|
| `on` | Enable the macro; this is used when no argument is supplied |
| `off` | Disable the macro |
| `-t+` | Enable “typing replaces block” (default) |
| `-t-` | Disable “typing replaces block” |
| `-t` | Toggle “typing replaces block” |
| `-p+` | Enable persistent blocks and disable “typing replaces block” |
| `-p-` | Disable persistent blocks |
| `-p` | Toggle persistent blocks |
| `-c` | Display the configuration menu |

Examples:

```text
cua
cua on
cua -c
cua -p+
cua off
```

On its first run without arguments, the macro enables itself and enables “typing replaces block.”

## Basic use

- Hold **Shift** while moving the cursor to mark a CUA-style character block.
- Hold **Alt** while extending the selection to mark a column block.
- Click and drag with the mouse to mark a character block.
- Use **Shift+click** to extend a character block.
- Use **Alt+click** or **Ctrl+click** to extend a column block.
- Click without dragging to unmark a CUA block.
- CUA-style Shift marking also works in prompt boxes.

Important keyboard commands include:

| Key | Action |
|---|---|
| **Ctrl+A** | Mark the entire file |
| **Ctrl+X** | Cut to TSE's system clipboard |
| **Ctrl+C** | Copy to TSE's system clipboard and retain the mark |
| **Ctrl+V** | Paste from TSE's system clipboard |
| **Shift+Delete** | Cut to the Windows Clipboard |
| **Ctrl+Insert** or **Ctrl+K ]** | Copy to the Windows Clipboard and retain the mark |
| **Shift+Insert** or **Ctrl+K [** | Paste from the Windows Clipboard |
| **Delete**, **Backspace**, or **Shift+Backspace** | Delete the marked CUA block; otherwise retain the key's normal behavior |
| **Ctrl+F** or **Ctrl+Q F** | Find text and mark the match as a CUA block |
| **Ctrl+L** | Repeat the previous search and mark the match |
| **Ctrl+Shift+L** | Repeat the search in the opposite direction |
| **Ctrl+Q A** or **Ctrl+R** | Replace within the marked block, or perform the normal Replace command if no CUA block is marked |
| **Ctrl+I** | Incremental search and mark the found text |

When “typing replaces block” is active, entering a normal character replaces the marked CUA block. The Enter key is excluded from this behavior.

## Help and troubleshooting

### `sc32.exe` cannot be found

Edit the `EDIR` line in `BURNIN.BAT` so it points to the TSE installation directory containing `sc32.exe`:

```bat
set EDIR=D:\Program Files\TSE
```

Do not place quotes in the `set EDIR=...` assignment and do not add a trailing backslash.

### `WORDSTAR.UI` cannot be found

Run `BURNIN.BAT` from the directory containing `WORDSTAR.UI`, or compile `WORDSTAR.UI` directly from within TSE.

### `CUA.MAC` does not load automatically

Confirm that `CUA.S` compiled successfully and that the resulting `CUA.MAC` is in a directory searched by TSE. You can also load or execute the compiled macro manually.

### The interface or keys differ from standard TSE

This package deliberately replaces many standard assignments with WordStar-compatible commands. Consult `CUAWS.TXT` for the full User's Guide supplement and `WSDIFF.TXT` for differences from WordStar behavior.

### Restoring the previous interface

Keep a backup before installation. To revert, restore the previous `.UI` source or compiled interface, compile it if necessary, and restart TSE. Disable the CUA macro with `cua off` or remove its automatic loading from your configuration.

## Notes

- `WORDSTAR.UI` and `CUA.S` are independent; either one can be used without the other.
- The supplied source dates from 2004 and was designed for the TSE versions listed above. Back up your configuration before testing it with a newer TSE release.
- The authoritative detailed documentation remains `CUAWS.TXT` in the original archive.

## Version history

| README version | Date and time | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-04 19:44:51 CEST (+0200) | Initial Markdown documentation based on `cuaws57.zip` |

Future README revisions should increment the last component sequentially, for example `1.0.0.0.1`, `1.0.0.0.2`, and `1.0.0.0.3`.

## Original copyright

CUAWS 5.7 and its included source and documentation are copyright 1997-2004 by Bill Stewart. Retain the original copyright and attribution notices when redistributing or modifying the package.
