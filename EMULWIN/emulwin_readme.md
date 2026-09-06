# EMULWIN — Windows-style keyboard interface for TSE Pro/32

**README version:** 1.0.0.0.0  
**Created:** 2026-09-06 22:46:12 UTC  
**Original package date:** 1999-02-24  
**Original author:** Al Stanbury  
**Target stated by the package:** The SemWare Editor Professional/32 (TSE Pro/32) v2.8

## Description

EMULWIN is a replacement user-interface definition for TSE Pro/32. It gives TSE many keyboard shortcuts familiar from Windows 95/98/NT applications and Windows word processors while retaining programming-oriented TSE features and a selection of WordStar commands.

The interface also provides menus, language-aware editing support, repeat-find shortcuts, recent-file handling, block operations, macro commands, and an adapted **Open File at Cursor** function that permits spaces in filenames.

This is a legacy TSE package. Back up the currently active user-interface and configuration files before installing it, especially when using a TSE version newer than the documented v2.8 target.

## Package contents

| File | Purpose |
| --- | --- |
| `EMULWIN.UI` | TSE user-interface source containing menus, hooks, commands, help text, and key definitions |
| `FILE_ID.DIZ` | Original short package description and author information |

## Main features

- Windows-style editing keys such as `Ctrl+C`, `Ctrl+X`, `Ctrl+V`, `Ctrl+F`, `Ctrl+H`, `Ctrl+O`, `Ctrl+N`, and `Ctrl+S`.
- Windows Clipboard support through `Ctrl+Shift+C`, `Ctrl+Shift+X`, and `Ctrl+Shift+V`.
- Repeat Find Forward with `Alt+Down` and Repeat Find Backward with `Alt+Up`.
- Open the filename at the cursor with `Ctrl+Shift+O`.
- Language-aware indentation and brace handling for supported programming files.
- Menus for file, editing, block, search, tools, options, windows, and help operations.
- Retains frequently used WordStar-compatible key sequences.
- Integrated key-assignment help through `Shift+F1`.

## Requirements

- A compatible 32-bit release of The SemWare Editor Professional.
- The TSE SAL compiler and normal TSE support macros if the interface must be compiled locally.
- Permission to write to the TSE installation or configuration directory.

The supplied package identifies TSE Pro/32 v2.8 as its target. Compatibility with modern TSE releases is not guaranteed because commands, configuration symbols, or supporting macros may have changed.

## Installation

1. Extract `emulwin.zip` to a temporary directory.
2. Close TSE.
3. Locate the active TSE user-interface source and compiled configuration files.
4. Back up those files before making any changes.
5. Copy `EMULWIN.UI` to the directory from which your TSE installation builds or loads its user interface.
6. Build or select `EMULWIN.UI` using the user-interface procedure documented for your installed TSE release. Older TSE releases commonly build `.UI` sources with the supplied SAL/configuration tools, but the exact command and output filename are release-dependent.
7. Start TSE and verify that the interface loads without an error.
8. Press `Shift+F1` and confirm that the **Key Assignments** help screen appears.

Do not overwrite your only working TSE interface. If your release expects a standard filename, first preserve the original and follow that release's UI installation instructions.

## How to run and use it

EMULWIN is not a standalone executable or an ordinary macro that is run once. It becomes active when TSE starts with the compiled/selected EMULWIN user interface.

After installation:

1. Start TSE normally.
2. Open or create a text file.
3. Try `Ctrl+S` to save, `Ctrl+O` to open a file, or `Ctrl+F` to search.
4. Press `F10` to open the main menu.
5. Press `Shift+F1` to see the full key-assignment reference included in the interface.

## Selected keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+C` | Copy selection |
| `Ctrl+X` | Cut selection |
| `Ctrl+V` | Paste |
| `Ctrl+Shift+C` | Copy to the Windows Clipboard |
| `Ctrl+Shift+V` | Paste from the Windows Clipboard |
| `Ctrl+F` | Find |
| `Ctrl+H` | Replace |
| `Alt+Down` | Repeat find forward |
| `Alt+Up` | Repeat find backward |
| `Ctrl+O` | Open/edit a file |
| `Ctrl+Shift+O` | Open file named at the cursor |
| `Ctrl+N` | Create a new file |
| `Ctrl+S` | Save the current file |
| `Ctrl+F4` | Close the current file |
| `Alt+F4` | Exit TSE |
| `F10` | Open the main menu |
| `F1` | Open Help |
| `Shift+F1` | Show all key assignments |

## Help and troubleshooting

### TSE does not start after installation

Restore the interface/configuration backup made before installation. Then check whether the installed TSE release supports the commands and configuration symbols used by this TSE Pro/32 v2.8 interface.

### Compilation reports missing symbols or macros

Confirm that the standard support files belonging to your TSE installation are available to the compiler. A newer release may require source changes because `EMULWIN.UI` was created in 1999 for TSE Pro/32 v2.8.

### A shortcut does not behave as expected

Press `Shift+F1` to inspect EMULWIN's active key assignments. Also check whether an additionally loaded macro has reassigned the same key.

### Return to the standard TSE interface

Close TSE, restore the backed-up interface/configuration files, and restart the editor.

## Version numbering

This README uses a five-part version number:

- `1.0.0.0.0` — initial README release.
- `1.0.0.0.1` — first small documentation revision.
- `1.0.0.0.2` — second small documentation revision, and so on.

Increase a more significant component when the package, compatibility information, or operating procedure changes substantially.

## License and warranty notice

The source header says the interface is supplied free of charge and may be used and modified as desired. It is provided without warranty or guarantee. Retain the original author notice when redistributing modified copies.

## Archive verification notes

This README was prepared by inspecting the supplied `emulwin.zip`. The archive contains two files and its original description identifies the program as `Emul_Win.ui` for TSE Pro/32 v2.8. No executable is included.
