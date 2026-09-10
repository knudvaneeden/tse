# HLPCLK20

**Session:** Create HLPCLK20 MarkDown Readme  
**README version:** 1.0.0.0.0  
**Date:** 2026-09-10  
**Time:** 22:34:48 UTC  
**Created with:** OpenAI GPT-5

## Description

HLPCLK20 contains **HlpLnClk version 2.00**, a mouse-interface macro for The SemWare Editor (TSE). While the macro is loaded, commands shown on TSE's help line can be executed by clicking them with the left mouse button.

For example, clicking the standard help-line entry:

```text
F10-Menu
```

pushes the corresponding `F10` key and opens the menu. The macro also recognizes help lines displayed while Ctrl, Alt, Shift, or combinations of those modifier keys are held.

The source identifies this release as version 2.00 dated 21 October 1996. It contains conditional code for both the Win32 and older DOS editions of TSE.

## Package contents

| File | Purpose |
| --- | --- |
| `HLPLNCLK.S` | TSE SAL source code for the macro. |
| `HLPLNCLK.DOC` | Original documentation, installation notes, usage instructions, and disclaimer. |
| `File_id.diz` | Short package description. |

The archive does not include a compiled `HLPLNCLK.MAC`; compile the supplied SAL source before installing it.

## Requirements

- The SemWare Editor (TSE) with mouse support.
- A compatible TSE SAL compiler, such as `SC32.EXE` for the Win32 edition.
- Permission to place the compiled macro in a directory searched by TSE.

Because this is historical source code, compatibility with recent TSE releases should be verified by compiling and testing it in the intended editor version.

## How to compile

1. Extract `hlpclk20.zip` to a working directory.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

   ```bat
   sc32 HLPLNCLK.S
   ```

4. Confirm that the compiler creates `HLPLNCLK.MAC` without errors.

If `SC32.EXE` is not in `PATH`, use its full pathname or run the command from the directory containing the compiler.

## How to install and run

HlpLnClk is designed to remain loaded during an editing session. The recommended setup is to add it to TSE's autoload list.

1. Copy `HLPLNCLK.MAC` to TSE's macro directory, or another directory in TSE's macro search path.
2. Start TSE and open any file.
3. Open the macro autoload list. In the original TSE interface this is done with:

   ```text
   F10, M, A
   ```

4. Press `Insert`.
5. Enter the macro name:

   ```text
   hlplnclk
   ```

6. Press `Enter` to accept the name, then press `Enter` again to finish.
7. Exit and restart TSE if necessary.

TSE should now load HlpLnClk automatically whenever the editor starts.

For a temporary test, load `HLPLNCLK.MAC` manually through TSE's macro-loading command instead of adding it to the autoload list.

## How to use

1. Look at the command entries on TSE's help line.
2. Move the mouse pointer over an entry such as `F10-Menu`.
3. Click it with the left mouse button.
4. HlpLnClk briefly highlights the entry and executes the corresponding key command.

Modifier-dependent help lines are supported. Hold Ctrl, Alt, Shift, or an applicable combination while clicking the displayed command.

If the macro cannot translate an entry into a valid key, it sounds an alarm, briefly marks the entry in red, and does not execute a command.

## Limitations

- Help-line entries must use the form `<key>-<description>`.
- Entries must be separated by spaces.
- The macro relies on standard TSE key definitions.
- It does not work with interactive macros that implement their own message loop and read input directly with `GetKey`; custom dialogs are a typical example.
- This package contains source code only and must be compiled before use.

## Removing the macro

Remove `hlplnclk` from TSE's autoload list and restart the editor. If the macro was loaded only for the current session, purge/unload it through TSE's macro facilities or restart TSE.

## Original release history

| Version | Date | Description |
| --- | --- | --- |
| 2.00 | 1996-10-21 | Merged with version 1.0 for TSE 2.5. |
| 1.91 | 1996-07-12 | Bug fixes. |
| 1.90 | 1996-07-03 | Adapted to TSE32. |
| 1.00 | 1996-03-29 | First release. |

## README version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 22:34:48 UTC | Initial Markdown description, help, compilation, installation, usage, limitations, and package inventory. |

Future revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Copyright and disclaimer

The original author, Dieter Kössl, donated the program to the public domain and permitted its use and alteration. The original documentation states that the program is used at the user's own risk.
