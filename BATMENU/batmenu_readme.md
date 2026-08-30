# BatMenu for TSE Pro

## Description

BatMenu is a TSE SAL macro that maintains and displays a menu of Windows batch-file commands. Each menu entry has a descriptive title and an associated block of batch commands stored in `BATMENU.DAT`.

Selecting an entry writes its commands temporarily to `C:\TSEBAT.BAT` and runs that batch file. The temporary batch file is removed afterward.

This repaired release is version **1.1.0.0.1**.

## Repairs in version 1.1.0.0.1

- Corrected the data-file lookup that could cause an empty menu.
- `BATMENU.DAT` is now searched for in this order:
  1. Beside the currently compiled `BATMENU.S` source file.
  2. Beside the loaded BatMenu macro.
  3. In the legacy `Mac` subdirectory below TSE's load directory.
- A clear warning is displayed if `BATMENU.DAT` cannot be found.
- Pressing **Escape** now closes BatMenu and returns to TSE instead of exiting the complete TSE editor.
- BatMenu's data and temporary buffers are closed when the menu finishes.

## Package contents

- `BATMENU.S` — TSE SAL source code.
- `BATMENU.DAT` — menu titles and their batch commands.
- `FILE_ID.DIZ` — short package description and version information.

## Requirements

- The SemWare Editor Professional (TSE Pro) for Windows.
- The TSE SAL compiler included with TSE.
- Permission to create and execute the temporary file `C:\TSEBAT.BAT`.

## Installation

1. Extract `batmenu_1.1.0.0.1.zip` into a working directory.
2. Keep `BATMENU.S` and `BATMENU.DAT` together in that directory.
3. Open `BATMENU.S` in TSE.
4. Compile it using TSE's **Macro Compile** command.
5. If desired, copy the compiled BatMenu macro and `BATMENU.DAT` to your normal TSE macro directory. Keep both files together.

If you use TSE's older directory layout, `BATMENU.DAT` may alternatively be placed in the `Mac` subdirectory below the TSE load directory.

## How to run BatMenu

### From an open TSE session

1. Load or execute the compiled `BatMenu` macro using your usual TSE macro command.
2. The **Bat files** list appears.
3. Move to the required title with the cursor keys.
4. Press **Enter** to execute its associated batch commands.
5. Press **Escape** to close BatMenu and return to TSE.

### From a Windows shortcut or command line

Use TSE's `-e` option to execute the compiled macro when TSE starts. Adjust the executable path for your installation.

For 32-bit TSE, an example is:

```text
C:\TSE32\E32.EXE -eBatMenu
```

For older 16-bit TSE installations, the original form was:

```text
C:\TSE\E.EXE -eBatMenu
```

## Menu controls

| Key | Action |
|---|---|
| **Enter** | Execute the selected batch-file entry. |
| **Escape** | Close BatMenu and return to TSE. |
| **E** | Edit the selected entry's batch commands. |
| **N** | Create a new entry or a copy of the selected entry. |
| **T** | Change the selected entry's title. |
| **U** | Move the selected entry up. |
| **D** | Move the selected entry down. |
| **S** | Sort the entry titles. |
| **Delete** | Delete the selected entry. |

## Editing the menu

Use BatMenu's own commands whenever possible:

1. Select an existing title.
2. Press **E** to edit its batch commands.
3. Save and leave the temporary batch-file editor to return the commands to `BATMENU.DAT`.
4. Use **T**, **U**, **D**, **S**, or **Delete** to manage the entry.

`BATMENU.DAT` contains control-character delimiters around each title. Editing those delimiters manually may make entries disappear from the list, so direct editing should be done carefully.

## Troubleshooting

### The macro reports that it cannot find `BATMENU.DAT`

- Confirm that `BATMENU.DAT` was extracted from the ZIP.
- Put `BATMENU.DAT` in the same directory as `BATMENU.S` before compiling and running the source.
- When running an already compiled macro, put `BATMENU.DAT` beside that macro.
- Alternatively, put it in TSE's legacy `Mac` subdirectory.

### The menu is empty

- Confirm that the correct `BATMENU.DAT` is being loaded.
- Confirm that the file is not empty.
- Restore the supplied `BATMENU.DAT` if its title-delimiter control characters were removed or changed.

### A selected command does not run

- Press **E** and verify the stored Windows batch commands.
- Check that Windows permits creation and execution of `C:\TSEBAT.BAT`.
- Test the same commands manually in `CMD.EXE`.

### Escape should not exit TSE

Version `1.1.0.0.1` returns normally to the open editor. If the complete editor still exits, verify that TSE is running the repaired macro rather than an older compiled copy.

## Safety note

BatMenu executes ordinary Windows batch commands with the permissions of the current user. Review unfamiliar entries before running them, especially commands that delete, overwrite, move, or rename files.

## Version

- BatMenu version: `1.1.0.0.1`
- Repair date: 30 August 2026
- Original author: Carlo Hogeveen
- Repairs and documentation: OpenAI GPT-5 Codex
