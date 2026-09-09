# FOLD131U

## Session

Create FOLD131U MarkDown Readme

## README version

**1.0.0.0.1**  
**Date:** 2026-09-09  
**Time:** 22:28:51 UTC

## Description

FOLD131U is the English/US edition of FOLD 1.31, a TSE SAL macro that turns The SemWare Editor into a simple folding editor or outliner. It was written for TSE 2.0 by Dirk Wissmann, with bug fixes and handling improvements by David Mayerovitch.

The macro lets you place sections of text between configurable fold markers. An open fold can then be collapsed into one descriptive line and reopened later. Closing a fold is possible from anywhere inside that fold; the cursor does not have to be on its opening marker.

The package contains:

- `FOLD.S` - SAL source code for the folding macro.
- `FOLD.CFG` - configuration of fold, closed-fold, and comment markers.
- `READ.ME` - original instructions, known limitations, history, and copyright information.
- `FILE_ID.DIZ` - short archive description.

## Main features

- Creates a new fold with a user-supplied description.
- Opens or closes the fold at the cursor.
- Closes an open fold from anywhere within that fold.
- Opens all closed folds or closes all open folds.
- Provides a menu for configuring fold and comment markers.
- Reads and saves `FOLD.CFG`.
- Opens stored folds before saving, quitting, or deactivating the macro to help prevent data loss.
- Includes built-in help.

## Requirements

- The SemWare Editor (TSE).
- A compatible TSE SAL compiler.
- `FOLD.S` and `FOLD.CFG` available during installation and configuration.

This source was originally adapted for TSE 2.0. A newer SAL compiler may report compatibility errors because the source uses historical SAL syntax and editor APIs.

## Installation and compilation

1. Extract `fold131u.zip` into a working directory.
2. Keep the configuration filename exactly as `FOLD.CFG`.
3. Open a command prompt in the extracted directory.
4. Compile the source with the TSE SAL compiler, for example:

   ```text
   sc32 fold.s
   ```

5. Confirm that the compiler creates `FOLD.MAC`.
6. Put `FOLD.MAC` and `FOLD.CFG` where your TSE installation can load them.
7. Load or execute the `FOLD` macro in TSE using your normal macro-loading method.

The original documentation states that the supplied source must be recompiled for the user's edition of TSE; a macro compiled by a different national edition may not be compatible.

## How to run FOLD131U

1. Open a text or source file in TSE.
2. Load or run the compiled `FOLD.MAC` macro.
3. If the file already contains open fold markers, FOLD prepares the file and initially closes the folds.
4. Use the commands below to create, close, and open folds.
5. Before saving or leaving TSE, use the macro's reassigned save and exit commands so all closed text is restored from its internal buffers.

## Default keys

The assignments in `FOLD.S` are examples and may be changed before recompiling.

| Key | Action |
| --- | --- |
| `Ctrl+F3` | Close all open folds |
| `Ctrl+F4` | Open all closed folds |
| `Ctrl+F6` | Save `FOLD.CFG` |
| `Ctrl+F8` | Read `FOLD.CFG` |
| `Ctrl+F10` | Create a new fold |
| `Ctrl+F11` | Close the current open fold |
| `Ctrl+F12` | Open the closed fold on the current line |
| `F12` | Open the configuration menu |
| `Alt+F2` | Display FOLD help |
| `Shift+F12` | Open all folds and deactivate the macro |
| `Alt+X` | Open closed folds and exit safely |
| `Ctrl+K`, `S` | Save safely |
| `Ctrl+K`, `X` | Save and quit safely |
| `Ctrl+K`, `Q` | Quit the current file safely |
| `Ctrl+K`, `D` | Quit the current file safely |

## Creating a fold

1. Position the cursor where the fold should be inserted.
2. Press `Ctrl+F10`.
3. Enter a unique description when prompted.
4. Add or move the desired text between the generated start and end marker lines.
5. Place the cursor anywhere inside the fold and press `Ctrl+F11` to close it.
6. Place the cursor on the resulting closed-fold line and press `Ctrl+F12` to open it again.

Do not use a period (`.`) in a fold description. The original implementation uses the description as the name of an internal system buffer, so descriptions should also be unique across all files currently loaded in TSE.

## Configuration

Press `F12` to configure the fold-start marker, fold-end marker, closed-fold marker, and programming-language comment delimiters. Presets are included for C/C++, Pascal, TeX, and TSE/C++-style comments.

The supplied `FOLD.CFG` contains settings similar to:

```text
startfold={{{
endfold=}}}
startcomment=//
endcomment=
closedfold=<character 255>...
```

Configuration rules:

- Do not insert spaces before or after `=`.
- Spell the setting names exactly as shown.
- Each configured marker is limited to six characters.
- The first character of the supplied `closedfold` value is character 255, not a normal space.
- The configuration lines may occur in any order.
- For Pascal comments, for example, use `startcomment=(*` and `endcomment=*)`.

## Important safety information

Closed-fold contents are temporarily held in TSE system buffers and are not saved automatically as ordinary file text. Use the macro's safe save, quit, and exit key assignments. These commands open all closed folds before the file is saved or removed.

Also observe these limitations from the original release:

- Nested folds are not supported and may cause data loss.
- Identical fold descriptions in different loaded files can overwrite the internal contents of an existing closed fold.
- Do not edit or damage a closed-fold marker line; the description on that line identifies its internal buffer.
- Opening all folds may position a fold incorrectly when its marker occurs on the first line of the file.
- Back up important files before first using this historical macro.

## Troubleshooting

### A closed fold will not open

- Put the cursor on the closed-fold marker line.
- Verify that the marker still matches the configured `closedfold` value.
- Check that no other loaded file used the same fold description.
- Do not rename the closed-fold description manually.

### FOLD reports that the cursor is not inside an open fold

Move the cursor onto the fold's start marker, end marker, or any line between them, then press `Ctrl+F11` again.

### The configuration is not read

- Confirm that the filename is exactly `FOLD.CFG`.
- Remove spaces surrounding `=`.
- Keep marker values within the six-character limit.
- Use `Ctrl+F8` to read the configuration again.

### The source does not compile

FOLD 1.31 dates from 1994 and targets TSE 2.0. Compile the included source for your own TSE edition. If a modern compiler rejects it, the historical syntax or API calls may need to be updated before recompilation.

## Original release information

- Program version: FOLD 1.31 English.
- Program date stated in `FOLD.S`: 1994-12-06.
- Final note in `READ.ME`: 1994-12-08.
- Original author: Dirk Wissmann.
- Improvements and significant bug fixes: David Mayerovitch.
- Copyright: 1993-1994 Dirk Wissmann.

Refer to the original `READ.ME` for the complete historical copyright and redistribution terms. The archive describes the program as freely redistributable only under its stated conditions and without a distribution fee, except for the limited media-cost exception described there.

## README version history

| Version | Date | Time | Changes |
| --- | --- | --- | --- |
| 1.0.0.0.0 | 2026-09-09 | 22:28:51 UTC | Initial Markdown description, help, installation, and run instructions. |
| 1.0.0.0.1 | 2026-09-09 | 22:28:51 UTC | Added default keys, configuration guidance, safety warnings, troubleshooting, and original release information. |
