# MACRO

## Version

**1.0.0.0.1**

## Date and time

**2026-09-20 21:44 CEST**

## Description

`MACRO` is a compiled TSE macro editor/helper package intended to assist with writing and working with TSE SAL macros.

The original package contains a compiled macro together with three text data files that provide SAL command, query, and setting information. When the macro is active it supplies a dedicated macro-editing environment, command/menu assistance, parameter prompts, and shortcuts for common macro-development operations.

The original `MACRO.DOC` states that `MACRO.DAT`, `MACRO.QRY`, and `MACRO.SET` should be placed in the same directory as the TSE program file, while `MACRO.MAC` should be placed in the configured compiled-macro directory.

This package preserves the original files and adds this README plus `macro.ini`.

Version 1.0.0.0.1 also includes `macro.s`. Its `Main()` displays the package information in several `Warn()` dialogs so each warning remains below TSE SAL's 255-character string limit. Each displayed line ends with `Chr(13)` for proper line breaks.

## Package files

| File | Purpose |
|---|---|
| `MACRO.MAC` | Original compiled TSE macro. |
| `MACRO.DAT` | SAL command and syntax reference data used by the macro. |
| `MACRO.QRY` | TSE query/value reference data. |
| `MACRO.SET` | TSE setting/parameter reference data. |
| `MACRO.DOC` | Original short installation and usage note. |
| `macro.ini` | Initialization/configuration companion file supplied with this package. |
| `macro_readme.md` | This documentation. |
| `macro.s` | Small standalone TSE SAL information launcher with `Main()`. |

## What the macro provides

From the strings and reference data in the original package, the macro provides a specialized TSE macro-editing environment with functions such as:

- SAL command and syntax lookup.
- Parameter help and prompts.
- Access to macro groups and command menus.
- Compile the current macro.
- Execute a compiled macro.
- Purge the Macro Editor from memory.
- Add, duplicate, swap, and edit lines.
- Delete from the cursor to the end of a line.
- Shift text.
- Shell to the operating system.
- Display SAL query and setting information.

The original status/help lines embedded in `MACRO.MAC` include these key descriptions:

- `F1` - Macro Editor/help entry.
- `F2` - Add line.
- `F4` - Duplicate line.
- `F5` - Scroll to top.
- `F6` - Delete to end of line.
- `F9` - Shell.
- `F10` - Menu.
- `Ctrl+F1` - Purge Macro Editor.
- `Ctrl+F2` - Swap lines.
- `Ctrl+F7` - Shift.
- `Ctrl+F9` - Compile.
- `Ctrl+F10` - Execute macro.
- `Esc` - Return to the editor from a macro menu.
- `Enter` - Select the highlighted menu item.

Exact behavior can depend on the TSE version and active key assignments.

## Installation

### Original installation layout

According to `MACRO.DOC`:

1. Put these files in the same directory as the TSE program executable:

   - `MACRO.DAT`
   - `MACRO.QRY`
   - `MACRO.SET`

2. Put `MACRO.MAC` in the directory configured for compiled TSE macros.

   The old documentation gives `\TSE\MAC\` as the historical default example.

3. Start TSE.

4. Load or execute the `MACRO` macro using the normal TSE macro mechanism for your installation.

### Portable testing

For a portable test, first try keeping all package files together. If the original compiled macro cannot locate `MACRO.DAT`, `MACRO.QRY`, or `MACRO.SET`, copy those three files to the directory containing the TSE executable, matching the layout required by the original program.

Because only the compiled `MACRO.MAC` is present and the SAL source code is not included, its original file-search logic cannot be changed directly without recreating or reverse-engineering the macro source.

## How to run

1. Install the files as described above.
2. Start TSE.
3. Load or execute `MACRO.MAC`.
4. Follow the message line and help-line prompts shown by the macro.
5. Use `F10` to open the macro menu when available.
6. Select commands with `Enter`.
7. Use `Esc` to return from a menu to the editor.
8. While editing a macro, use the displayed function-key shortcuts for editing, compiling, and executing it.

The original documentation summarizes operation as: execute the macro, then follow the message and help-line prompts.

## Typical macro-editing workflow

1. Open or create a `.s` SAL source file in TSE.
2. Activate the `MACRO` macro/editor.
3. Edit the SAL source normally.
4. Use the built-in command/syntax lookup when SAL syntax or parameters are needed.
5. Use `Ctrl+F9` to invoke the macro compile function.
6. Correct any reported compiler errors.
7. After a successful compile, use `Ctrl+F10` to execute the compiled macro.
8. Use `Ctrl+F1` if you want to purge the Macro Editor from memory.

## Reference data files

### `MACRO.DAT`

Contains SAL command entries and syntax descriptions. Examples found in the file include commands such as `Ask()`, `AddLine()`, `EditFile()`, `ExecMacro()`, `Find()`, `GetText()`, and many others.

### `MACRO.QRY`

Contains queryable TSE state/settings information and descriptions, including items such as `AutoIndent`, `BufferType`, `CurrVideoMode`, `FindOptions`, `MacPath`, and many others.

### `MACRO.SET`

Contains setting names together with parameter formats or accepted values. It documents, for example, ON/OFF values, numeric ranges, strings, and named constants for many TSE settings.

These files reflect the TSE/SAL version for which this historical macro was originally built. Some entries may differ from modern TSE 4.50 behavior.

## `macro.ini`

`macro.ini` is included as a package initialization/configuration companion file. The original compiled `MACRO.MAC` predates this package addition and there is no source code in the supplied archive showing that it reads an INI file.

Therefore, the current `macro.ini` is **not assumed to control the original `MACRO.MAC` automatically**. It records filenames and optional path settings in one place for documentation and for a possible future source-based modernization.

Default entries are deliberately simple and portable. Empty path values mean that the normal/original file locations should be used.

## Compatibility notes

- The supplied `MACRO.MAC` is an already compiled historical TSE macro.
- No `.s` source file is included in the original archive.
- The data files are plain ASCII text.
- The compiled macro may have been built for an older TSE version and should therefore be tested carefully with TSE 4.50.x.
- If the macro does not find its data files, follow the original layout and place `MACRO.DAT`, `MACRO.QRY`, and `MACRO.SET` beside the TSE executable.
- Keep a backup of the original package before experimenting with modified files.

## Troubleshooting

### The macro loads but reference information is missing

Verify that `MACRO.DAT`, `MACRO.QRY`, and `MACRO.SET` can be found. The original documentation requires these files to be in the TSE program directory.

### TSE cannot find `MACRO.MAC`

Copy `MACRO.MAC` to the directory configured as the TSE macro path, or execute it using the full path if your TSE version supports that workflow.

### A documented key does something else

Your current TSE configuration or another loaded macro may already use that key. Check the active key assignments and invoke the function through the macro menu when possible.

### Compilation behavior differs from current TSE SAL

The supplied command database dates from the original package era. Use the help supplied with your current TSE/SAL compiler as the authoritative reference for modern syntax and compiler behavior.

## Original documentation

The supplied `MACRO.DOC` says, in summary:

1. Place `MACRO.DAT`, `MACRO.QRY`, and `MACRO.SET` in the TSE program directory.
2. Place `MACRO.MAC` in the configured compiled-macro directory.
3. Execute the macro.
4. Follow the message and help-line prompts.

## Package

All original and added files are stored in:

`macro1.0.0.0.0.zip`
