# FL - WordPerfect-style File Manager for TSE

**Session:** Create FL MarkDown Readme  
**README version:** 1.0.0.0.12  
**Date:** 2026-09-09  
**Time:** 14:37:09 UTC  

## Description

FL is a TSE SAL macro that provides a simple WordPerfect 5.2-style file manager inside The SemWare Editor (TSE). It displays the files and subdirectories of a selected directory together with their sizes, dates, times, and DOS attributes.

From the file list, you can load, view, copy, delete, rename, or print a file. You can also move between directories, mark several files for a copy or delete operation, change file attributes, sort the list, and view the directory of a ZIP archive.

The Windows DLL package contains:

- `FL.S` - updated ASCII TSE SAL source code.
- `fl32.c` - Win32 DLL source code.
- `fl32.def` - undecorated DLL export definitions for TSE.
- `build.bat` - Borland C++ 5.5.1 build script.
- `fl_readme.md` - this documentation.

This edition replaces the DOS-era `WP.BIN` helper with `fl32.dll`. The DLL uses the native Windows functions `FindFirstFile`, `FindNextFile`, `FindClose`, and `SetFileAttributes`.

## Building the Windows DLL

1. Check the `BCCBIN` and `BCCLIB` paths in `build.bat`.
2. Run `build.bat` from a Windows command prompt.
3. A successful build ends with `Built fl32.dll successfully.`
4. Keep `fl32.dll` where 32-bit TSE can find it. Normally, keep it with the macro and start TSE with that directory available through the Windows DLL search path.
5. Restart TSE after rebuilding the DLL because Windows may keep a loaded DLL in memory until TSE exits.

## Main features

- Lists files and subdirectories.
- Shows file size, date, time, and attributes.
- Loads a selected file into TSE for editing.
- Views a file without replacing the current editing context.
- Copies, deletes, renames, and prints files.
- Marks multiple files for copy or delete operations.
- Changes Read-only, Archive, System, and Hidden attributes.
- Sorts by name, extension, size, date, or time.
- Changes directory and supports `..` for the parent directory.
- Views a ZIP directory by running an external unzip command.
- Restores the starting directory when FL is closed unless the user deliberately changed directories from the file list.

## Requirements

- The SemWare Editor with a SAL compiler compatible with this source.
- `fl32.dll` built with the supplied Win32 source and definition file.
- Borland C++ 5.5.1 when rebuilding the DLL.
- A DOS/Windows command environment that supports the commands used by this historical macro.
- An `unzip` program on the system `PATH` for ZIP-directory viewing.
- A valid `TEMP` environment variable for the temporary ZIP listing file.

> **Compatibility note:** This is a 32-bit DLL for 32-bit TSE on Microsoft Windows. The original FL display and operations still use the historical DOS 8.3 filename layout. The DLL prefers the Windows short-name alias when one exists.

## Installation and compilation

1. Extract `fl_windows_dll_1.0.0.0.12.zip` into a working directory.
2. Run `build.bat` to create `fl32.dll`.
3. Keep `FL.S` and `fl32.dll` together.
4. Compile the source with the 32-bit TSE SAL compiler:

   ```text
   sc32 fl.s
   ```

5. Confirm that the compiler creates the compiled macro file, normally `FL.MAC`.
6. Copy or move the compiled macro to a directory from which TSE can load macros, or leave it in the working directory and supply its full path when loading it.

If compilation succeeds but the macro will not load, verify that Windows can locate `fl32.dll`. The DLL must match the 32-bit architecture of TSE.

## How to run FL

1. Start TSE.
2. Load or execute the compiled `FL` macro using the normal TSE macro-loading command.
3. At the `Dir:` prompt, enter the directory or file specification to list.
4. Press **Enter** to open the list.
5. Move through the list with the cursor keys, **Page Up**, and **Page Down**.
6. Use the commands below to work with the selected item.
7. Press **Escape** or **F7** to close FL.

## Commands and keys

| Key | Action |
| --- | --- |
| `R` or `1` | Retrieve/load the selected file into TSE and close FL. |
| `Enter`, `L`, `V`, or `6` | View the selected file, or enter the selected subdirectory. |
| `D` or `2` | Delete the selected file, or all marked files after confirmation. |
| `M` or `3` | Move/rename the selected file. |
| `P` or `4` | Print the selected file. |
| `C` or `8` | Copy the selected file, or all marked files. |
| `O` or `7` | Prompt for another directory or file specification. |
| `Space` or numeric keypad `*` | Mark or unmark the selected item. |
| `A` | Change the selected file's attributes. |
| `S` | Sort the displayed list. |
| `Z` | View the contents of the selected ZIP archive. |
| `.` | Go to the parent directory (`..`). |
| `F1` or `F3` | Display the built-in FL help screen. |
| `Escape` or `F7` | Exit the file manager. |

The corresponding shifted letter keys are also defined for most letter commands.

## Marking and operating on several files

1. Move the cursor to a file.
2. Press **Space** or numeric keypad **\*** to mark it.
3. Repeat for each required file.
4. Press `C` to copy all marked files, or `D` to delete all marked files.
5. Respond to the confirmation prompts.

The mark is shown as an asterisk in the file list. Directories should not be included in a multi-file operation.

## Sorting the list

1. Press `S`.
2. Select one of the available sort fields:
   - Name
   - Extension
   - Size
   - Date
   - Time
3. FL sorts the list and attempts to return the cursor to the filename that was selected before the sort.

## Changing file attributes

1. Select a file and press `A`.
2. Toggle one or more of these DOS attributes:
   - Read Only
   - Archive
   - System
   - Hidden
3. Select **Set them** to apply the chosen attributes.

The attribute column uses `R`, `H`, `S`, `A`, and `D`; an underscore means that the corresponding attribute is not set.

## Viewing ZIP contents

Select a ZIP file and press `Z`. FL runs:

```text
unzip -vb filename.zip
```

The command output is redirected to a temporary file named `$ZIPDIR$.$$$` under the directory specified by `TEMP`, displayed in TSE, and then deleted.

If this command does not work, verify that:

- A compatible `unzip` executable is installed.
- The executable is available through the system `PATH`.
- The `TEMP` environment variable identifies a writable directory.

## Important cautions

- File deletion is permanent; FL does not move deleted files to the Recycle Bin.
- FL clears a file's Read-only attribute before deleting it.
- Confirm the selected directory and marked files carefully before copying or deleting.
- The source formats filenames in the historical DOS 8.3 layout; long filenames may not display or operate correctly.
- ZIP viewing and copying rely on external command-line behavior and may need adjustment on modern systems.

## Troubleshooting

### `fl32.dll` cannot be loaded

Build `fl32.dll`, verify that it is a 32-bit DLL, and place it where Windows can find it while TSE is running. Restart TSE after replacing an older copy of the DLL.

### The macro does not compile in a recent TSE SAL compiler

The 1994 source still contains historical SAL constructs. This edition removes the old binary helper and keeps the SAL file ASCII-only, but additional source adjustments may be necessary for a substantially different compiler release.

### ZIP viewing fails

Run `unzip -vb` from a command prompt to confirm that the external utility exists and accepts that option. Also check that `TEMP` points to a writable directory.

### Copying reports an error even though a file was copied

FL detects success by searching command output for the exact text `1 file(s) copied`. Localized or newer command output can differ, causing a false error report.

### Long filenames appear truncated or malformed

FL was designed around DOS 8.3 filenames. Use short filenames or update the listing, parsing, and column-layout code for long-filename support.

## Version history

| Version | Date | Time | Changes |
| --- | --- | --- | --- |
| 1.0.0.0.12 | 2026-09-09 | 17:57:27 UTC | Removed all string parameters from `FLBUILDLIST` after Windows error 123 confirmed a TSE-to-DLL string-marshalling problem. The DLL now enumerates `*.*` in the current directory and constructs its `%TEMP%` listing filename internally. |
| 1.0.0.0.11 | 2026-09-09 | 17:49:02 UTC | Removed obsolete SAL buffer parsing helpers and changed Win32 enumeration to use the filename pattern relative to the directory already selected by TSE, avoiding Windows error 123 from the full expanded search string. |
| 1.0.0.0.10 | 2026-09-09 | 17:44:32 UTC | Removed obsolete SAL wrappers that still referenced the retired `FLFINDFIRST` and `FLFINDNEXT` DLL exports. |
| 1.0.0.0.9 | 2026-09-09 | 17:30:00 UTC | Reverted the unsafe `__pascal` experiment that caused TSE to crash. Reworked directory enumeration so the `__stdcall` DLL writes a temporary list file instead of writing directly into a SAL string buffer. Added numeric Windows error reporting. Both the DLL and macro must be rebuilt. |
| 1.0.0.0.8 | 2026-09-09 | 17:16:00 UTC | Corrected the DLL functions from `__stdcall` to the Borland `__pascal` calling convention required by TSE. Standardized the Pascal exports as uppercase `FLFINDFIRST`, `FLFINDNEXT`, and `FLSETATTR`. The DLL must be rebuilt for this version. |
| 1.0.0.0.7 | 2026-09-09 | 17:10:00 UTC | Restored explicit `Chr(0)` terminators on filenames and search paths passed from SAL to the native Win32 DLL. This fixes directory enumeration returning no file list. |
| 1.0.0.0.6 | 2026-09-09 | 17:06:23 UTC | Removed obsolete Win16 `_COLOR_` and `AttrSet` cursor-attribute logic. Removed duplicate Shift+R and Shift+Z key definitions reported by the Win32 SAL compiler. |
| 1.0.0.0.5 | 2026-09-09 | 17:02:30 UTC | Renamed the legacy `CopyFile` helper to `FNIntegerCopySelectedFileI` because `CopyFile` is reserved by SAL Compiler V4.50.rc23. |
| 1.0.0.0.4 | 2026-09-09 | 16:59:18 UTC | Renamed the complete legacy `ff*` helper family to unique SAL-compatible procedure names, including the reserved `ffTime` identifier. |
| 1.0.0.0.3 | 2026-09-09 | 16:56:54 UTC | Renamed the `ffName` SAL helper to `FNStringFileFindNameS` because `ffName` is a reserved keyword in SAL Compiler V4.50.rc23. |
| 1.0.0.0.2 | 2026-09-09 | 16:53:14 UTC | Corrected `fl32.def` to export the exact undecorated Borland `PUBDEF` names reported by `tdump`, eliminating the non-public-symbol linker warnings. |
| 1.0.0.0.1 | 2026-09-09 | 14:37:09 UTC | Added the Microsoft Windows 32-bit DLL edition, Borland C++ build files, ASCII-only SAL source, DLL installation guidance, and native Windows file API notes. |
| 1.0.0.0.0 | 2026-09-09 | 14:37:09 UTC | Initial Markdown documentation for the supplied FL package. Added the description, requirements, installation, compilation, operating instructions, key reference, cautions, and troubleshooting information. |

Future documentation revisions should increment the final component in sequence: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original program history

- March 1993 -- Original release with TSE v1 by Richard Blackburn.
- September 1994 -- Clean-up for TSE v2.
- October 18, 1994 -- Fixed restoration of settings after exiting the main prompt.
- October 24, 1994 -- Dave Gwillim added ZIP viewing, starting-directory restoration, and cursor restoration after sorting.
- October 25, 1994 -- Fixed deletion of Read-only files.
- November 9, 1994 -- Consolidated fixes and changes from multiple authors.
