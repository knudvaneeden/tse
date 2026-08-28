# FppPack 1.04 Portable for TSE Pro

## Description

`FppPack_1_04_portable.zip` contains four TSE SAL macros for entering, evaluating, and summarizing mathematical expressions in TSE Pro:

- `FPPShell.s` — interactive expression evaluator and number-format display.
- `FPPSum.s` — calculates a sum from a marked column block.
- `FPPSumLine.s` — evaluates expressions line by line in a marked column block.
- `GetFileVersion.s` — helper macro used to verify the required EXE and DLL versions.

The calculation engine is provided by `FppCon_x64.exe` or `FppCon_x86.exe`. `BO_Helper.dll` supplies supporting Windows functions.

This portable edition does not require the EXE and DLL files to be stored beside `g32.exe` or `e32.exe`. The macros locate all support files relative to their own macro directory, so the complete `mac` directory can be placed in any TSE SAL working directory.

## Included versions

| File | Version |
|---|---:|
| `FPPShell.s` | 1.1.32.100 |
| `FPPSum.s` | 1.0.0.85 |
| `FPPSumLine.s` | 1.0.0.83 |
| `BO_Helper.inc` | 1.0.0.9 |
| `GetFileVersion.s` | 1.0.0.1 |
| `FppCon_x64.exe` | 2.4.3.26 |
| `FppCon_x86.exe` | 2.4.3.26 |
| `BO_Helper.dll` | 1.9.1.29 |

## Requirements

- TSE Pro for Windows, GUI (`g32.exe`) or console (`e32.exe`).
- Windows 7 or newer; the supplied files were originally tested on Windows 11 Pro.
- All files from the ZIP's `TSEPro/mac` directory must remain together.

## Installation and compilation

1. Extract `FppPack_1_04_portable.zip`.
2. Copy the complete `TSEPro/mac` directory to any desired directory, for example:

   ```text
   G:\TSE_SAL\FppPack\
   ```

3. Confirm that this working directory contains at least:

   ```text
   BO_Helper.dll
   BO_Helper.inc
   FppCon_x64.exe
   FppCon_x86.exe
   FppError.h
   FppHelp.txt
   FPPShell.s
   FPPSum.s
   FPPSumLine.s
   GetFileVersion.s
   ```

4. Open `GetFileVersion.s` in TSE Pro and compile it first.
5. Compile `FPPShell.s`, `FPPSum.s`, and `FPPSumLine.s`.
6. Keep the resulting `.mac` files in the same directory as the source and support files. In particular, `GetFileVersion.mac` must be present beside the other files.

The directory does not need to be beside `g32.exe`/`e32.exe`, and it does not need to be included in TSE's configured macro search path.

## Running FPPShell

1. In TSE Pro, choose **Macro > Execute**.
2. Select or enter the full path of `FPPShell.mac` in the portable working directory.
3. Type an expression, for example:

   ```text
   1 + 2 * 3
   ```

4. Press **Enter** to evaluate it.
5. Press **Esc** to close FPPShell and return to the TSE editor.

If the portable working directory is already included in TSE's macro path, entering `FPPShell` in **Macro > Execute** is sufficient.

## FPPShell keyboard help

| Key | Action |
|---|---|
| `Enter` | Evaluate the current expression. |
| `Esc` | Close FPPShell. |
| `F1` | Open FPPShell help. |
| `Alt+F` | Show known functions. |
| `Alt+V` | Show known variables. |
| `Alt+T` | Show known constants/templates. |
| `Alt+L` | Show the generated code list for the last expression. |
| `Alt+O` | Open the options menu. |
| `Alt+I` | Select the integer display format. |
| `Alt+S` | Select the floating-point display format. |
| `Ctrl+1`, `Ctrl+2`, `Ctrl+3` | Decrease the base used by display line 1, 2, or 3. |
| `Alt+1`, `Alt+2`, `Alt+3` | Increase the base used by display line 1, 2, or 3. |

The three configurable display bases range from 2 through 36. FPPShell also displays signed and unsigned integer interpretations, hexadecimal values, and IEEE single- and double-precision representations.

## Running FPPSum

1. Open a text file containing numbers.
2. Mark the values as a **column block**.
3. Choose **Macro > Execute** and run `FPPSum.mac` from the portable working directory.
4. Use the displayed commands and menus to calculate and inspect the sum.

`FPPSum` requires a marked column block. It displays a message if no column block is marked.

## Running FPPSumLine

1. Open a text file containing one expression per line.
2. Mark the expressions as a **column block**.
3. Choose **Macro > Execute** and run `FPPSumLine.mac` from the portable working directory.
4. The macro evaluates the marked expressions line by line and inserts or displays the results according to its selected options.

## Portable file lookup

The original package used `LoadDir()`, which points to the directory containing `g32.exe` or `e32.exe`. Version 1.04 instead:

- obtains the macro directory from `CurrMacroFilename()`;
- uses that directory for `BO_Helper.dll` and `FppCon_x86.exe`/`FppCon_x64.exe`;
- registers the directory with Windows before the first DLL call;
- invokes `GetFileVersion.mac` through its quoted full pathname.

This also supports working-directory paths that contain spaces.

## Troubleshooting

### `Path not found: GetFileVersion.mac`

Compile `GetFileVersion.s` first and keep `GetFileVersion.mac` in the same directory as `FPPShell.mac`, `FPPSum.mac`, and `FPPSumLine.mac`. Then recompile the three main macros from version 1.04.

### `BO_Helper.dll` cannot be found

Confirm that `BO_Helper.dll` is in the same directory as the compiled macros. Do not move only the `.mac` files to another directory.

### `FppCon_x64.exe` or `FppCon_x86.exe` cannot be found

Confirm that both EXE files are in the same directory as the macros. The correct executable is selected automatically for a 64-bit or 32-bit Windows system.

### An old version still runs

TSE may be loading another copy from its normal macro path. Execute the new `FPPShell.mac` by its full pathname, or remove/rename the older compiled copy. Recompile all four sources after replacing the files.

### FPPSum or FPPSumLine reports that a column block is required

Mark the input using TSE's column-block selection rather than a line or stream block, then run the macro again.

## Exiting

Press **Esc** in the FPPShell main window. In lists, help screens, and most secondary windows, **Esc** closes the current window and returns to the previous screen.
