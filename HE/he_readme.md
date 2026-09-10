# HE / HEXEDIT — Hexadecimal Editor Macro for TSE

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-10 21:29:53 UTC  
**Documentation created by:** OpenAI Codex (GPT-5)

## Description

HE is a hexadecimal viewing and editing package for The SemWare Editor (TSE). Its main macro, `HEXEDIT`, displays the hexadecimal value of binary data beside the original bytes. The display is divided into 16-byte rows and includes the hexadecimal starting address of every row.

The archive contains the original SAL source, a compiled macro, documentation, and a DOS batch file for opening a file in binary mode.

## Archive contents

| File | Purpose |
| --- | --- |
| `HEXEDIT.S` | TSE SAL source code for the hexadecimal editor macro. |
| `HEXEDIT.MAC` | Original compiled macro supplied with the package. |
| `HEXEDIT.DOC` | Original documentation by Frank M. Villafane. |
| `H.BAT` | Starts TSE with a specified file in 16-byte binary mode and loads `HEXEDIT.MAC`. |

## Features

- Displays up to 16 bytes per line in hexadecimal notation.
- Shows the starting hexadecimal address of each line.
- Highlights the hexadecimal byte corresponding to the cursor position.
- Toggles hexadecimal mode with **Alt+H**.
- Edits the current byte by entering a two-digit hexadecimal value.
- Jumps directly to a hexadecimal file address.
- Refreshes the hexadecimal display on demand.
- Includes a batch-file method for opening binary files correctly.

## Key commands

| Key | Action |
| --- | --- |
| **Alt+H** | Turn hexadecimal mode on or off. |
| **Alt+E** | Edit the byte at the current cursor position. |
| **Alt+G** | Go to a hexadecimal address. |
| **F5** | Refresh the hexadecimal display. |
| **Page Up** | Move to the previous screen of data. |
| **Page Down** | Move to the next screen of data. |
| **Arrow keys** | Move between bytes while hexadecimal mode is active. |
| **F10** | Open the normal TSE menu. |

## Installation

1. Extract all files from `he.zip` into one directory.
2. If necessary, compile `HEXEDIT.S` with the SAL compiler belonging to your TSE installation.
3. Keep the resulting `HEXEDIT.MAC` in the working directory, a directory listed in `TSEPath`, or an appropriate TSE `MAC` directory.
4. If you want to use `H.BAT`, ensure that the TSE executable invoked as `E` is available through the DOS `PATH`, or adapt the batch file to the correct executable path.

The supplied `HEXEDIT.MAC` is an old compiled version. Recompiling the source is recommended when using a different TSE release, although this historical SAL source may require compatibility changes for recent TSE versions.

## How to run it

### Method 1 — Use the included batch file

From a DOS or Windows command prompt, change to the directory containing the HE files and run:

```bat
H filename
```

Replace `filename` with the binary file to inspect. `H.BAT` runs this command internally:

```bat
E -B16 -EHEXEDIT.MAC %1
```

The `-B16` option opens the file in binary mode with 16 bytes per line, while `-EHEXEDIT.MAC` loads the macro. After TSE starts, press **Alt+H** to display the hexadecimal view.

### Method 2 — Load the macro from TSE

1. Open the required file in binary mode, using 16 bytes per line.
2. Load `HEXEDIT.MAC` through TSE's macro-loading facility.
3. Press **Alt+H** to turn on hexadecimal mode.
4. Press **Alt+H** again when you want to return to the normal display.

## Editing a byte

1. Turn on hexadecimal mode with **Alt+H**.
2. Move the cursor to the byte to change.
3. Press **Alt+E**.
4. Enter exactly two hexadecimal digits, for example `00`, `2A`, or `FF`.
5. The macro updates the byte and refreshes the hexadecimal display.
6. Save the file normally in TSE when the changes are correct.

Work on a backup copy when editing an important binary file. Changing even one byte can make a program or data file unusable.

## Going to a hexadecimal address

1. Press **Alt+G** while hexadecimal mode is active.
2. Enter a hexadecimal address of up to eight digits.
3. The cursor moves to the corresponding byte when the address is valid.
4. An error message is displayed if the address lies outside the file.

## Display behavior and limitations

- The original data occupies the left side of the screen; addresses and hexadecimal byte values appear to its right.
- Hexadecimal mode uses a temporary hidden buffer and a restricted window layout.
- Cursor movement is limited to the currently displayed hexadecimal page. Use **Page Up** and **Page Down** to move between pages.
- The macro turns insert mode off when hexadecimal mode starts, when insert mode was previously enabled.
- The original macro does not restore that earlier insert-mode state when hexadecimal mode is turned off.
- The package dates from 1993 and was written for an older TSE/SAL environment. Some syntax, configuration variables, screen behavior, or compiled-macro formats may not be compatible with TSE Pro 4.50 without source changes.
- The batch file uses the historical executable name `E`; installations using another executable name must adapt `H.BAT`.

## Troubleshooting

### Alt+H does nothing

- Confirm that `HEXEDIT.MAC` was loaded successfully.
- Check whether another macro already uses **Alt+H**.
- Recompile `HEXEDIT.S` for the installed TSE version if the supplied compiled macro cannot be loaded.

### The hexadecimal display is misaligned

- Open the file in binary mode with exactly 16 bytes per line.
- Use a screen width sufficient for the original bytes, address, and hexadecimal representation.
- Press **F5** to refresh the display.

### The wrong byte is shown or edited

- Verify that the file was opened with the `-B16` option.
- Do not change the binary line width while hexadecimal mode is active.
- Toggle hexadecimal mode off and on, or press **F5**, to rebuild the display.

### The source does not compile with a modern SAL compiler

The source uses identifiers and syntax from an early SAL release. Review compiler errors individually and adapt the source to the documented rules of the installed compiler. Keep the original `HEXEDIT.S` unchanged as a reference and make compatibility changes in a copy.

## Version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 21:29:53 | Initial Markdown description, help, installation, usage, key reference, limitations, and troubleshooting guide for `he.zip`. |

Future revisions should increment the final component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original author information

The original `HEXEDIT.DOC` identifies **Frank M. Villafane** as the author and states that the macro is supplied as-is. See that document in the archive for the original notes and historical contact details.
