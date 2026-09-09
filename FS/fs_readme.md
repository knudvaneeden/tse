# FS - File Settings Macro Package for TSE

## Description

FS is a macro package for The SemWare Editor (TSE) that maintains selected editor settings separately for each file in the editor ring. This is useful when editing several types of files at the same time, because each file can retain suitable tab, indentation, wrapping, and margin settings.

The supplied source was written for TSE 2.5. The ready-to-run `FS.MAC` file is included in the package.

FS tracks these settings for every file:

- `TabType` (hard, soft, smart, or variable)
- `TabWidth`
- `VarTabs` (variable tab stops)
- `ExpandTabs`
- `WordWrap`
- `AutoIndent` (off, on, or sticky)
- `LeftMargin`
- `RightMargin`
- `RemoveTrailingWhite`

When a file is opened for the first time during an editor session, FS chooses initial settings according to its filename and extension. When the user changes to another file, FS saves the old file's settings and restores the settings associated with the new file.

The settings are maintained only during the current TSE session; they are not saved between editor sessions.

## Package Contents

- `FS.MAC` - compiled TSE macro, ready to load or execute
- `FS.S` - SAL source code
- `FS.TXT` - original documentation

## Installation

1. Extract `fs.zip` to a directory accessible to TSE.
2. Copy `FS.MAC` to the TSE macro directory, or retain its full path for loading.
3. Start TSE.
4. Add `FS.MAC` to TSE's AutoLoad List:
   1. Open the **Macro** menu.
   2. Select **AutoLoad List...**.
   3. Press **Insert**.
   4. Enter `fs.mac`, or enter its complete path if it is stored outside the macro directory.
5. Restart TSE or load the macro manually.

Once loaded, FS works automatically in the background whenever the active file changes.

## How to Run FS

### Display the help screen

Execute the macro without a parameter:

```text
fs
```

Loading FS through the AutoLoad List activates its file-settings management without displaying the help screen.

### Show the current file settings

```text
fs -c
```

This opens the **Current Settings** menu and allows the settings for the active file to be changed.

### Show the default settings

```text
fs -m
```

This opens the **Default Settings** menu. These defaults are used as the starting point when FS encounters a new file.

### Save TSE settings safely

```text
fs -s
```

Use this command in place of TSE's normal `SaveSettings()` operation. FS temporarily restores the default settings before saving, so the settings belonging only to the current file are not accidentally stored as TSE's defaults.

### Open TSE's full configuration safely

```text
fs -i
```

Use this command in place of directly executing `iconfig`. FS temporarily switches to the default settings while the configuration macro is active.

### Display the tracking buffer

```text
fs -d
```

This diagnostic command lists the internal settings records maintained for the files in the ring.

## Optional Menu Entries

The original documentation recommends replacing the normal configuration and save-settings menu commands. The following entries can be added to the `OptionsMenu()` definition in the active TSE `.UI` file:

```text
"Remove Trailing White"
        [OnOffStr(Query(RemoveTrailingWhite)):3],
        Toggle(RemoveTrailingWhite), DontClose
"Current  >", ExecMacro("fs -c"), DontClose
"Defaults  >", ExecMacro("fs -m"), DontClose
"&Full Configuration  >", ExecMacro("fs -i"), DontClose
"&Save Current Settings  >", ExecMacro("fs -s")
```

Recompile and load the modified user-interface macro according to the normal TSE procedure.

## Default File-Type Behavior

The supplied `FSDecideSettings()` procedure assigns initial settings based on the filename or extension. Examples include:

- `.doc` and `.txt`: automatic word wrapping, soft tabs, and document-oriented margins
- `.s`, `.ui`, `.si`, `.c`, `.h`, `.cpp`, `.hpp`, `.rc`, `.idl`, and `.mak`: programming-oriented indentation and hard tabs
- `.asm`, `.inc`, `.prg`, and `.pas`: hard tabs with language-specific tab widths
- `makefile`: hard tabs with a tab width of 4
- `.uue`: trailing whitespace removal disabled

Edit `FSDecideSettings()` in `FS.S` if different defaults are preferred.

## Compiling the Source

`FS.MAC` is already compiled and can be used directly. The source contains a binary declaration for `bitset.bin`, but that external file is not included in this archive. Consequently, recompiling `FS.S` may require the compatible original `bitset.bin` file and a suitable historical TSE SAL compiler.

If all required dependencies are available, compile from a command prompt with the appropriate SAL compiler, for example:

```text
sc32 fs.s
```

Use the compiler appropriate for the TSE version on which the macro will run. Keep the original `FS.MAC` as a backup before replacing it with a newly compiled version.

## Help and Troubleshooting

### FS does not remember settings

- Confirm that `FS.MAC` is loaded, preferably through the AutoLoad List.
- Confirm that the macro remains loaded while changing between files.
- Remember that settings are not retained after TSE closes.

### A new file receives unsuitable settings

Modify the extension rules in `FSDecideSettings()` and recompile the macro. The routine first applies the stored defaults and then overrides selected settings for recognized file types.

### Saving settings stores the current file's values as defaults

Use `fs -s` instead of the ordinary save-settings command. Use `fs -i` instead of directly running `iconfig`.

### The source will not compile

The most likely cause is the missing `bitset.bin` dependency referenced by `FS.S`, or an incompatibility between this TSE 2.5-era source and a newer SAL compiler. The included compiled `FS.MAC` does not need to be recompiled for ordinary use on a compatible TSE installation.

### The help-screen key does nothing

`HELP_SCREEN_KEY` is set to `0` in the supplied source, so no help key is assigned by default. Change that constant to a preferred key definition and recompile the macro, or execute `fs` without a parameter to display help.

## Customization

To track another editor setting, the original design requires corresponding changes in three procedures:

1. `_InsertSettings()` - store the setting in the internal tracking buffer.
2. `_RestoreSettings()` - restore the setting from the tracking buffer.
3. `FSDecideSettings()` - choose its initial value for a newly encountered file.

The stored and restored values must remain in exactly the same order.

## Original Author and License Note

The package identifies Christopher Antos as its author. Its original documentation permits modification, customization, and redistribution, but prohibits selling the macro. It is supplied as-is and should be used at the user's own risk.

## Version History

### 1.0.0.0.0 - 2026-09-10 01:33:21 CEST

- Created the initial Markdown documentation for the FS package.
- Added a package description, feature summary, installation steps, commands, help, and troubleshooting information.

### 1.0.0.0.1 - 2026-09-10 01:33:21 CEST

- Clarified the distinction between loading and executing `FS.MAC`.
- Documented all supported command-line parameters.
- Added the original menu-integration guidance and default file-type behavior.
- Added compilation notes concerning the absent `bitset.bin` dependency.

