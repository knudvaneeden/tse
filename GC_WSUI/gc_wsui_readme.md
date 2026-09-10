# GC_WSUI — WordStar-style interface for TSE Pro 4 GUI

## Document information

- **README version:** 1.0.0.0.1
- **Date:** 2026-09-10
- **Time:** 10:10:34 UTC
- **Package:** `gc_wsui.zip`
- **Original author:** Grafton Cole
- **Original interface date:** 2002-12-04
- **Target editor:** The SemWare Editor Professional (TSE Pro) 4 GUI

## Description

GC_WSUI is a customized TSE Pro 4 GUI user interface based on WordStar-style keyboard commands. It extends the familiar WordStar command families with additional editing, navigation, block, file, window, search, help, clipboard, and macro functions.

The interface primarily uses keyboard commands instead of menus. In particular:

- `Ctrl+J` commands are mainly used for help and list functions.
- `Ctrl+M` commands are mainly used for external macros and macro-control functions.
- `Ctrl+K` commands handle many block and file operations.
- `Ctrl+Q` commands provide navigation, search, and position functions.

The package also supplies a matching configuration file with the author's display, color, file, keyboard, history, tab, margin, printing, and GUI settings.

## Package contents

| File | Description |
| --- | --- |
| `TSE4GUI.UI` | Customized TSE Pro 4 GUI user-interface source file. |
| `TSE4GUI.cfg` | Configuration included by `TSE4GUI.UI`. It must remain available when the UI is compiled. |
| `Readme.txt` | Original notes from Grafton Cole. |
| `file_id.diz` | Short archive description. |

## Main features

- WordStar-oriented keyboard layout.
- File saving, loading, reloading, renaming, and quitting commands.
- Character, word, line, column, and block operations.
- Multiple-window navigation and resizing.
- Forward and backward find operations.
- Recent-file, bookmark, function, and string lists.
- TSE and Microsoft Windows clipboard commands.
- Macro recording, loading, execution, debugging, and compilation shortcuts.
- Quick Help and indexed TSE help commands.
- Configurable word sets, tabs, margins, line drawing, wrapping, and auto-indent.
- Syntax highlighting and customized GUI colors.

## Important precautions

This package replaces or substantially changes the normal TSE user interface. Make backup copies of your current TSE UI, executable, configuration, and related files before testing it.

The original author warns that the command-line code is critical. Do not modify that part of the source unless you understand how it works.

This interface was created for TSE Pro 4 GUI in 2002. Newer TSE releases may contain renamed, changed, or removed SAL symbols. Compile and test the interface in a separate TSE installation or test directory first.

## Installation

1. Create a separate test directory for GC_WSUI.
2. Extract all files from `gc_wsui.zip` into that directory.
3. Keep `TSE4GUI.UI` and `TSE4GUI.cfg` together. The UI source contains:

   ```text
   #include ["TSE4gui.cfg"]
   ```

4. Back up the files in your existing TSE installation that will be replaced.
5. Open a command prompt configured for your TSE installation and SAL compiler.
6. Change to the directory containing the extracted files.
7. Compile `TSE4GUI.UI` using the UI-building procedure documented for your exact TSE Pro version. If your installation supports the standard SC32 UI build form, use:

   ```bat
   sc32 -e TSE4GUI.UI
   ```

8. Check the compiler output and correct every error before using the generated interface.
9. Install or copy the generated editor/interface file according to the instructions for your TSE version.
10. Start TSE and verify the keyboard commands in a disposable test file.

Do not overwrite your working TSE installation until the test build starts and operates correctly.

## How to use it

After the customized interface has been built and activated, open a test text file in TSE. Commands consisting of two control keys are entered as a sequence. For example, `Ctrl+K`, followed by `S`, saves the current file.

### Common file commands

| Keys | Action |
| --- | --- |
| `Ctrl+K`, `S` | Save the current file. |
| `Alt+K`, `S` | Save all files. |
| `Ctrl+K`, `X` | Save and close the current file. |
| `Ctrl+K`, `Q` | Quit the current file and ask whether to save changes. |
| `Ctrl+K`, `T` | Save As. |
| `Ctrl+K`, `O` | Open or edit a file. |
| `Ctrl+Page Up` | Select the next file. |
| `Ctrl+Page Down` | Select the previous file. |

### Navigation and search

| Keys | Action |
| --- | --- |
| `Ctrl+Q`, `R` | Go to the beginning of the file. |
| `Ctrl+Q`, `C` | Go to the end of the file. |
| `Ctrl+Q`, `F` | Find text. |
| `Ctrl+Q`, `A` | Replace text. |
| `Ctrl+Q`, `I` | Go to a line. |
| `Ctrl+L` | Repeat the find operation forward. |
| `Ctrl+Q`, `L` | Repeat the find operation backward. |

### Block commands

| Keys | Action |
| --- | --- |
| `Ctrl+K`, `K` | Mark a character block. |
| `Ctrl+K`, `L` | Mark the current line. |
| `Ctrl+K`, `H` | Mark the current word. |
| `Ctrl+K`, `U` | Unmark the block. |
| `Ctrl+K`, `C` | Copy the block. |
| `Ctrl+K`, `V` | Move the block. |
| `Ctrl+K`, `Y` | Delete the block. |
| `Ctrl+K`, `R` | Insert a file. |
| `Ctrl+K`, `W` | Save the block. |

### Clipboard commands

| Keys | Action |
| --- | --- |
| Numeric keypad `*` | Paste from the TSE clipboard. |
| Numeric keypad `+` | Copy to the TSE clipboard. |
| Numeric keypad `-` | Cut to the TSE clipboard. |
| `Alt+P` | Paste from the Microsoft Windows clipboard. |
| `Alt+C` | Copy to the Microsoft Windows clipboard. |

### Help commands

| Keys | Action |
| --- | --- |
| `F1` | Display the interface Quick Help. |
| `F2` | Open the TSE Help index. |
| `F3` | Open the Help table of contents. |
| `F4` | Show help for the word at the cursor. |
| `F5` | Return to the previous Help topic. |
| `F6` | Search Help. |
| `F10` | Open the main menu. |

The complete set of active key definitions is located near the end of `TSE4GUI.UI`.

## External macro dependencies

Some key assignments call external macros that are not included in this archive. These include names such as `JUSTIFY`, `CAPITAL`, `ISRCH`, `LISTOPEN`, `NAMECLIP`, `COMPILE`, `MAKE_PG`, `GLOB_FR`, `SPELLCHK`, `STATE`, `POTPOURR`, `SYNCHSCR`, and `UNLOAD`.

Those commands work only when the corresponding macros are installed and accessible through TSE's macro path. Missing external macros do not necessarily prevent the UI from compiling, but invoking their assigned keys can produce a runtime error.

## Configuration notes

`TSE4GUI.cfg` contains personal settings from the original author. Review it before installation, especially:

- the `HyperFont` font selection;
- the 113-column by 40-row startup video mode;
- file backup and protected-save settings, which are disabled;
- display colors and syntax-highlight colors;
- tab stops, margins, and default file extensions;
- recent-file and command-history settings.

If `HyperFont` is unavailable, change `FontName` and related font settings to values supported by your system.

## Troubleshooting

### The compiler cannot find `TSE4gui.cfg`

Keep `TSE4GUI.cfg` in the same directory as `TSE4GUI.UI`, preserve its filename, and run the compiler from the extracted package directory.

### Compilation reports undefined or invalid SAL symbols

The interface targets TSE Pro 4 GUI. Verify that you are using a compatible TSE and SC32 version. For a newer release, compare the source with the standard UI source supplied with that release and port changed procedures carefully.

### A key reports that a macro cannot be found

The command probably calls one of the external macros listed above. Install that macro or change/comment out its key definition in `TSE4GUI.UI`.

### The display or font is incorrect

Review `StartupVideoMode`, `FontName`, `FontSize`, `FontFlags`, and the color attributes in `TSE4GUI.cfg`. The original values depend on the author's older Windows and TSE environment.

### TSE no longer starts after installation

Restore the backup of your original TSE interface or executable, then rebuild GC_WSUI in a separate test directory.

## Version history

| Version | Date | Time | Changes |
| --- | --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 | 10:10:34 UTC | Initial Markdown documentation. |
| 1.0.0.0.1 | 2026-09-10 | 10:10:34 UTC | Expanded installation, usage, keyboard, dependency, configuration, safety, and troubleshooting information. |

## Credits

GC_WSUI and the original notes were created by Grafton Cole. TSE Pro and the SAL compiler are products of SemWare Corporation.
