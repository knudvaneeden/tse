# ExpTabs (`exptabs2`)

**README version:** 1.0.0.0.0  
**Created:** 2026-09-07 01:26:55 CEST (UTC+02:00)  
**Original macro:** ExpTabs Version 2, dated 1999-06-21  
**Original author:** Carlo Hogeveen  
**Target:** The SemWare Editor (TSE) Pro / TSE Pro/32

## Description

ExpTabs is a TSE SAL macro that finds physical tab characters in the current file and replaces them with the appropriate number of spaces.

Before changing the file, the macro analyzes lines containing tabs and estimates the tab width with which the file was originally created. It then displays the relevant lines so that the user can inspect the alignment, adjust the proposed tab width, and explicitly accept or cancel the conversion.

Version 2 of the original macro fixes a problem that occurred when a non-default tab width was selected.

## Package contents

- `EXPTABS.S` — TSE SAL source code for the macro.
- `FILE_ID.DIZ` — short description from the original distribution.

## What the macro does

1. Searches the current file for physical tab characters.
2. Examines suitable pairs of lines to estimate the original tab width.
3. Shows a preview and the proposed tab width.
4. Lets the user change the width and inspect other tabbed lines.
5. Replaces every physical tab in the current file with spaces only after the user presses **Enter**.

If the file contains no physical tabs, the macro makes no changes.

## Installation and compilation

1. Extract `exptabs2.zip` to a temporary directory.
2. Copy `EXPTABS.S` to the directory in which you keep TSE macro source files, normally TSE's `mac` directory.
3. Open a command prompt in that directory.
4. Compile the source with the appropriate TSE SAL compiler. For a 32-bit TSE installation, a typical command is:

   ```text
   sc32 EXPTABS.S
   ```

5. Confirm that compilation completes successfully and creates the compiled macro file used by your TSE installation.
6. Start or restart TSE when necessary so that it can load the newly compiled macro.

The archive is an older TSE distribution. Compiler commands and output extensions can differ between TSE versions, so consult the documentation supplied with your installed editor if `sc32` is not available.

## How to run it manually

1. Open the file whose tabs you want to convert.
2. Execute the compiled `exptabs` macro from TSE's macro execution command or menu.
3. If tabs are found, press any key after the first notification to enter the preview.
4. Inspect the proposed alignment and adjust the tab width if necessary.
5. Press **Enter** to accept the displayed tab width and replace all physical tabs in the current file with spaces.
6. Save the file if the result is correct.

## Preview keys

| Key | Action |
| --- | --- |
| **Left Arrow** | Decrease the tab width, down to a minimum of 1. |
| **Right Arrow** | Increase the tab width, up to a maximum of 16. |
| **Up Arrow** | Move to the previous interesting line containing tabs. |
| **Down Arrow** | Move to the next interesting line containing tabs. |
| **Home** or **Ctrl+PgUp** | Move to the beginning of the file. |
| **End** or **Ctrl+PgDn** | Move to the end of the file. |
| **Enter** | Accept the chosen width and convert the tabs to spaces. |
| **Escape** | Cancel without converting the file. |

## Optional automatic checking

The original macro can also be added to TSE's **Macro AutoLoad List**. In that mode it hooks TSE's first-edit event and checks an opened file when editing begins. You can still execute the macro manually for the current file.

The exact way to edit the AutoLoad list depends on the installed TSE version. Add the compiled macro under its macro name, `exptabs`, using TSE's macro configuration facilities.

## Important notes

- The conversion affects every physical tab in the current file after confirmation.
- **Escape** cancels the operation and leaves the file unchanged.
- Make a backup or ensure the file is under version control before processing important material.
- Review the alignment before saving. The tab-width detection is an estimate and may not be correct for every file.
- The maximum selectable and detectable tab width is 16.
- The macro temporarily changes TSE's `TabWidth` and `ExpandTabs` settings while working, then restores their previous values.
- The macro is intended for text files. Do not use it on binary files.
- The source and messages use the historical spelling `TabWith` in one prompt; it means `TabWidth`.

## Troubleshooting

### The compiler is not found

Run the command from the directory containing the TSE SAL compiler, add that directory to `PATH`, or invoke the compiler by its full path.

### TSE cannot execute the macro

Verify that the macro compiled successfully and that the compiled file is in a directory searched by TSE. Also verify that you execute it as `exptabs`, not as the ZIP filename.

### The proposed indentation looks wrong

Use **Left Arrow** and **Right Arrow** to select the width that displays the intended alignment. Press **Enter** only when the preview is correct; otherwise press **Escape**.

### Tabs appear to remain after conversion

Search the file for a literal tab after running the macro. If tabs remain, make sure the conversion was accepted with **Enter**, and confirm that the file is editable rather than read-only.

## Version history

| README version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-07 01:26:55 CEST | Initial Markdown documentation created from `EXPTABS.S` and `FILE_ID.DIZ`. |

Future documentation revisions should increment the final component, for example: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Credits

ExpTabs was written by Carlo Hogeveen. This README documents the files supplied in `exptabs2.zip`.
