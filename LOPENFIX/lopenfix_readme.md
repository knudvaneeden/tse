# LOPENFIX

**Version:** 1.0.0.0.6  
**Date:** 2026-09-19  
**Time:** 19:41 CEST (UTC+02:00)  
**Target:** The SemWare Editor (TSE), SAL macro source

## Description

`LOPENFIX.S` contains a small collection of TSE SAL routines that improve navigation and handling of the list of open files.

Its main functions are:

- Remember the first file/buffer that was loaded.
- Play a short beep when `NextFile()` or `PrevFile()` wraps around to that first file.
- Make the open-file list begin with the first file instead of the currently selected file.
- Allow the current file to be designated as the new "first" file with `MakeFirst()`.

The original source assigns:

- `<Alt N>` to `mNextfile()`
- `<Alt P>` to `mPrevfile()`

These assignments can be changed to match the key assignments used in your own TSE configuration.

## TSE SAL source formatting

This package keeps SAL statements on a single physical source line where continuation would otherwise be needed. TSE SAL does **not** use `\` as a line-continuation character.

## Important: not a stand-alone macro

The original `LOPENFIX.S` is explicitly designed to be incorporated into the TSE user-interface macro source rather than loaded as an independent macro.

At minimum, the following must be integrated into the user-interface source:

```text
integer firstID = 0
```

and the `OnFirstEdit()` procedure logic that initializes `firstID` with the buffer ID of the first edited file.

The current package is self-contained with respect to the list display and uses TSE's built-in `List()` command.

## Files

The package contains:

- `LOPENFIX.S` - original SAL source code.
- `READ.ME` - original short description supplied with the source.
- `lopenfix_readme.md` - this expanded description, help, and installation guide.
- `lopenfix.ini` - configuration/reference file supplied with this package.

## What each routine does

### `OnFirstEdit()`

When the first file is edited, this procedure stores its buffer ID in the global variable `firstID`.

It only sets the value when `firstID` is still zero, so later files do not replace the original first-file marker automatically.

### `mNextfile()`

Calls TSE's `NextFile()` and checks whether the resulting buffer ID equals `firstID`.

If it does, a short tone is played to indicate that navigation has wrapped around to the first file.

### `mPrevfile()`

Works like `mNextfile()`, but uses `PrevFile()` to move in the opposite direction.

A short tone is played when the first file is reached.

### `MakeFirst()`

Changes `firstID` to the buffer ID of the current file.

This makes the current file the new logical "first" file for:

- the wrap-around beep; and
- the starting position of the open-file list.

The procedure displays:

```text
Current File Now Marked as the First
```

after the change.

The original source does not assign a key to `MakeFirst()`. You can assign one in your own user-interface source if desired.

### `mListOpenFiles()`

This is a modified version of the open-file-list routine from `TSE.S`.

The important change is that the routine begins enumeration at `firstID`:

```text
GotoBufferId(FirstID)
```

instead of beginning at the currently active file.

Consequently, the first file remains at the top of the displayed buffer list.

Changed files are marked with `*`, consistent with the original routine's behavior.

## How to install

Because `LOPENFIX.S` is not stand-alone, do not simply compile and load it expecting all functions to become active automatically.

### Step 1 - Back up your user-interface source

Make a backup copy of the TSE user-interface SAL source that you currently compile and use, for example `TSE.S` or your customized equivalent.

### Step 2 - Add the global variable

Add the following global variable with the other global declarations:

```text
integer firstID = 0
```

Do not declare a second variable with the same name if your user-interface source already contains it.

### Step 3 - Integrate `OnFirstEdit()`

Merge the logic from the supplied `OnFirstEdit()` procedure into the `OnFirstEdit()` procedure used by your user interface:

```text
if firstID == 0
    firstID = GetBufferID()
endif
```

If your user interface already has an `OnFirstEdit()` procedure, add the statements to that existing procedure instead of creating a duplicate procedure with the same name.

Ensure that the user-interface event/hook arrangement used by your TSE configuration actually invokes `OnFirstEdit()`.

### Step 4 - Add the navigation procedures

Copy these procedures into the user-interface source:

- `mNextfile()`
- `mPrevfile()`

They call TSE's normal file-navigation commands and add the short notification tone when the first file is reached.

### Step 5 - Add `MakeFirst()`

Copy `MakeFirst()` into the user-interface source.

Optionally assign a key to it. The original source supplies no key assignment for this procedure.

### Step 6 - Replace or integrate the open-file-list routine

If you want the open-file list always to start with the first file, integrate the supplied `mListOpenFiles()` implementation.

If your existing user-interface source already contains an `mListOpenFiles()` procedure, replace or merge it rather than defining a duplicate procedure.

### Step 7 - Check the key assignments

The original source contains:

```text
<Alt n> mNextfile()
<Alt p> mPrevfile()
```

Keep these assignments or change them to keys that do not conflict with your current TSE setup.

### Step 8 - Compile the user-interface source

Compile the modified user-interface SAL source with the TSE SAL compiler appropriate for your installed TSE version.

For example, if `sc32.exe` is available in your command path, compile your normal user-interface source in the same manner you already use for TSE SAL files.

The important point is that the integrated user-interface source is compiled; `LOPENFIX.S` itself was not originally designed as a separately loaded macro.

### Step 9 - Load/use the compiled user interface

Start TSE using your newly compiled user-interface configuration, following the same procedure you normally use for your customized TSE interface.

## How to test

1. Start TSE with the modified user interface.
2. Open two or more files.
3. Press `<Alt N>` repeatedly.
4. When navigation returns to the first file, a short beep should sound.
5. Press `<Alt P>` repeatedly and verify the same behavior in reverse navigation.
6. Invoke your open-file-list command and verify that the originally first file appears at the top of the list.
7. Move to another file and invoke `MakeFirst()` using whichever command or key you assigned to it.
8. Verify that the message `Current File Now Marked as the First` is displayed.
9. Repeat the navigation and file-list tests. The newly marked file should now behave as the first file.

## `lopenfix.ini`

Version 1.0.0.0.5 adds runtime INI support. `LOPENFIX.S` looks for `lopenfix.ini` in the same directory as the executing compiled macro, using `CurrMacroFilename()`. This keeps the package portable.

The supported entries are:

- `soundfrequency=300` - frequency passed to `Sound()`. Set to `0` or a negative value to suppress the wrap-around tone.
- `sounddelay=1` - delay used before `NoSound()`. Values less than or equal to zero skip the delay.
- `usemodifiedfilelist=true` - when true, `mListOpenFiles()` starts the list at `firstID`; when false, it starts at the current file, matching the old unmodified behavior.
- `usemakefirst=true` - enables `MakeFirst()`. When false, `MakeFirst()` leaves `firstID` unchanged and displays a message that the feature is disabled.
- `nextfilekey=<Alt N>` - reference/documentation only.
- `prevfilekey=<Alt P>` - reference/documentation only.

The two key entries cannot be applied dynamically because SAL key assignments such as `<Alt n> mNextfile()` are compile-time syntax. To change those keys, edit the key definitions in `LOPENFIX.S` (or in the integrated user-interface source) and recompile.

Boolean INI values accept `true/false`, `yes/no`, `on/off`, or `1/0`. Invalid boolean values fall back to the built-in default. Missing integer values also fall back to their built-in defaults.

## Notes and limitations

- The source identifies the first file by TSE buffer ID, not by filename.
- `firstID` is initialized only when the `OnFirstEdit()` logic runs while its value is zero.
- Closing the buffer currently stored in `firstID` may require selecting a new first file with `MakeFirst()` depending on how the surrounding user-interface code handles closed buffers.
- The notification tone now uses the INI-controlled `soundfrequency` and `sounddelay` values; the default remains frequency 300 and delay 1.
- The original source uses a 65-character local filename string in `mListOpenFiles()`. This is inherited from the older code and may be more restrictive than modern path lengths.
- Key assignments can conflict with an existing user interface and should be reviewed before compilation.
- The package does not replace the need to back up a customized `TSE.S` or equivalent user-interface source before modifying it.

## Troubleshooting

### No beep is heard

Check that:

- `firstID` has been initialized;
- the `OnFirstEdit()` logic is actually invoked;
- `<Alt N>` and `<Alt P>` are bound to `mNextfile()` and `mPrevfile()`;
- system/TSE sound output is available; and
- another macro or user-interface definition has not replaced those key assignments.

### The open-file list does not start with the first file

Check that the active `mListOpenFiles()` implementation contains:

```text
GotoBufferId(FirstID)
```

and that the command you invoke actually calls this modified routine rather than another open-file-list implementation.

### Duplicate procedure errors

If your user-interface source already defines `OnFirstEdit()` or `mListOpenFiles()`, merge the LOPENFIX changes into the existing procedures rather than copying a second complete procedure with the same name.

## Version history

### 1.0.0.0.0 - 2026-09-19 19:04 CEST

- Created expanded Markdown documentation.
- Added detailed description of all LOPENFIX routines.
- Added installation and integration instructions.
- Added step-by-step testing instructions.
- Added troubleshooting information.
- Added `lopenfix.ini` as a configuration/reference file.
- Preserved the original `LOPENFIX.S` and `READ.ME` in the distribution package.

## Package

Distribution archive:

```text
lopenfix1.0.0.0.4.zip
```


## Version 1.0.0.0.2

- Corrected `Query(BufferType)` to `BufferType()` for TSE SAL 4.50 compatibility.


## Version 1.0.0.0.4

- Replaced obsolete `IsChanged()` with `FileChanged()` for TSE SAL 4.50 compatibility.

### Version 1.0.0.0.4
- Replaced the external `ListIt()` dependency with TSE's built-in `List()`.
- Added local list-width calculation and capped it at `Query(ScreenCols)`.
- `LOPENFIX.S` no longer requires `ListIt()` from `TSE.S`.

### 1.0.0.0.5 - 2026-09-19 19:38 CEST

- Added runtime reading of `lopenfix.ini`.
- `soundfrequency` now controls the wrap-around tone frequency.
- `sounddelay` now controls the delay before `NoSound()`.
- `usemodifiedfilelist` now switches between first-file and current-file list ordering.
- `usemakefirst` now enables or disables `MakeFirst()`.
- `nextfilekey` and `prevfilekey` remain reference-only because SAL key assignments are compile-time definitions.
- INI lookup is portable and uses the directory of the executing compiled macro.
- Removed the unused local `total` variable.
