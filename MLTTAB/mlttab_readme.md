# MLTTAB / MULTITAB

Version: 1.0.0.0.2  
Updated: 2026-09-22 12:55:26 UTC  
Updated with: OpenAI GPT-5.6

## Description

`MULTITAB.S` is a TSE SAL macro that maintains separate editing settings for each open file and can save default settings for each filename extension.

The macro manages these TSE settings:

- Tab width
- Tab type: Hard, Soft, Smart, or Variable
- Auto-indent mode: Off, On, or Sticky
- Word wrap
- Right margin
- Left margin

The settings of an open file are saved when TSE changes to another file and restored when that file is selected again. Defaults saved for a file type are automatically applied to newly opened files with the same extension.

## Package files

- `MULTITAB.S` - TSE SAL source code
- `mlttab.ini` - startup-message setting
- `mlttab_readme.md` - this documentation

The old precompiled `MULTITAB.MAC` from the original 1994 archive is not included in this updated package. Old `.MAC` files may be incompatible with newer TSE SAL/editor versions and would not contain the version 1.0.0.0.2 changes. Compile `MULTITAB.S` with your own TSE SAL compiler.

## Version history

- 1.0.0.0.2 - Replaced the invalid `Toggle(WordWrap)` statement with an explicit `Set(WordWrap, ...)` operation for current TSE SAL.
- 1.0.0.0.1 - Renamed the original `CurrExt()` procedure to `GetCurrentExtension()` because `CurrExt` is a reserved keyword in current TSE SAL.
- 1.0.0.0.0 - Added the README, INI-controlled startup warning, and updated packaging.

## INI setting

Keep `mlttab.ini` in the same directory as the compiled macro. The supported parameter is:

```ini
silent=false
```

- `silent=false` shows an informative `Warn()` box when the macro is run manually. This is the default.
- `silent=true` suppresses that startup `Warn()` box.

The install menu opens in both modes. The setting only controls the startup message.

## Compile

1. Extract all package files into one directory.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

```text
sc32 MULTITAB.S
```

4. Verify that the compiler creates `MULTITAB.MAC` without errors.
5. Keep `MULTITAB.MAC` and `mlttab.ini` together in the same directory.

## Run and install

1. Start TSE.
2. Load or execute `MULTITAB.MAC` in the usual way for your TSE installation.
3. When `silent=false`, acknowledge the informative startup message.
4. The **MULTITAB Install** menu opens.
5. Choose **Add MULTITAB to AutoLoad list** if the macro should load automatically whenever TSE starts.

The same menu can remove MULTITAB from the AutoLoad list.

## Change settings

Use either method:

- Press `<Ctrl O>` followed by `<Tab>`.
- Run the macro and choose **Change tab settings** from the install menu.

In the MULTITAB menu, change the desired tab, indentation, wrapping, and margin values. Choose **Set as Default for type** to save the current settings as the default for the current filename extension.

For example, settings saved while editing a `.s` file become the defaults for subsequently opened `.s` files.

## Generated configuration file

MULTITAB maintains its file-type defaults in a `.cfg` file derived from the macro filename. This file is created or updated automatically. Do not confuse that internal lookup table with `mlttab.ini`, which controls only the startup warning.

## Notes

- Save and back up important work before testing an older macro on a modern TSE installation.
- The macro was originally written for TSE 2.0 in 1994 and has been updated here with the requested startup message and INI option.
- If the shortcut conflicts with another macro, change the final key assignment in `MULTITAB.S` and recompile it.
- If the INI file is absent or the value is not `true`, the startup warning is shown.
