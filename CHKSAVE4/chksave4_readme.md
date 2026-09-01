# ChkSave 4 for TSE Pro

**README version:** 1.0.0.0.0  
**Created:** Wednesday, 02 September 2026 at 00:42:15 CEST  
**Original macro:** ChkSave version 4, dated 26 February 1999  
**Author:** Carlo Hogeveen (`hyphen@xs4all.nl`)

## Description

ChkSave is a TSE SAL macro that protects a loaded file from being overwritten accidentally when another program or process changes the file on disk during an editing session.

The macro periodically compares the saved file's date and time with the information recorded when TSE loaded or last saved it. If an external change is detected, ChkSave lets the user decide how to proceed.

ChkSave version 4 was written specifically for **The SemWare Editor Professional (TSE Pro) 2.50e**. The original documentation recommends `Chgnot13.zip` instead for 32-bit TSE versions.

## Archive contents

| File | Description |
| --- | --- |
| `CHKSAVE.S` | TSE SAL source code for ChkSave version 4 |
| `FILE_ID.DIZ` | Short archive description |

## Main features

- Detects when another process changes a file that is currently loaded in TSE.
- Checks normal files, but does not check TSE hidden or system files.
- Avoids checking while the user is typing, so normal editing is not unnecessarily slowed down.
- Offers to compare or reload a file when an external change is detected during editing.
- Adds overwrite and no-save choices when the user attempts to save a changed file.
- Restarts its tracking when a file is renamed inside TSE.
- Uses TSE's `CmpFiles` macro when the Compare option is selected.

## Requirements

- TSE Pro 2.50e, or a compatible TSE version whose SAL compiler supports the functions and hooks used by the macro.
- The standard `CmpFiles` macro must be available if the Compare option is used.
- Permission to compile a macro and update TSE's macro autoload list.

> **Compatibility note:** This source was designed for the older TSE Pro 2.50e environment. It is not the recommended ChkSave/ChgNot implementation for a 32-bit TSE installation.

## Installation

1. Extract `CHKSAVE.S` from `chksave4.zip`.
2. Copy `CHKSAVE.S` to TSE's macro source directory, normally the `MAC` directory below the TSE installation directory.
3. Start TSE.
4. Compile `CHKSAVE.S` with TSE's SAL macro compiler.
5. Add `ChkSave` to TSE's macro autoload list so that it loads automatically whenever TSE starts.
6. Restart TSE, or load the compiled macro manually for the current session.

The exact compile and autoload commands depend on the TSE version and local installation. Consult the TSE Macro/SAL documentation if those commands are not already configured.

## How to run it

ChkSave is intended to run automatically after it has been compiled and added to the macro autoload list. It has no normal command-line parameters and does not need to be started for each file.

1. Open a normal disk file in TSE.
2. Leave the file loaded.
3. Change and save the same file from another editor, program, script, or process.
4. Return to TSE and wait for ChkSave's next check. The default interval is approximately five seconds while TSE is idle.
5. Respond to the prompt displayed by ChkSave.

## Prompts and choices

### External change detected during editing

ChkSave displays:

```text
File updated by another process: C(ompare), R(eload) or <escape>?
```

- `C` — runs `CmpFiles` so that the loaded and disk versions can be compared.
- `R` — discards the loaded contents and reloads the current file from disk.
- `Esc` — keeps the currently loaded contents and temporarily ignores the external change. ChkSave checks again when the file is saved.

### External change detected while saving

ChkSave displays:

```text
File updated by another process: C(ompare), O(verwrite), R(eload) or N(osave)?
```

- `C` — compares the loaded version with the disk version, then returns to the choice prompt.
- `O` — saves the loaded TSE contents and overwrites the externally changed disk file.
- `R` — reloads the disk version and prevents the pending save.
- `N` — cancels the save and keeps the loaded buffer unchanged.

Use `O` carefully because it replaces changes made by the other process.

## Configuration

The check interval is controlled near the start of `CHKSAVE.S`:

```sal
#define wait_time 5
```

The value is expressed in seconds. A smaller value detects changes sooner but performs disk checks more often. A larger value reduces checking activity but delays notification. Recompile the macro after changing this value.

The source also uses this temporary filename:

```sal
string temp_filename [255] = "c:\\chksave.tse"
```

The root of drive `C:` must therefore be writable when ChkSave needs this temporary name. If that path is unsuitable, change it to a valid writable location and recompile the macro. The temporary name should not identify an important existing file.

## Notes for macro authors

The original source distinguishes between two ways of saving from another macro:

- Use `SaveFile()` when ChkSave should check the save operation and the saved file remains loaded afterward.
- Using `SaveAs(CurrFilename(), _overwrite_)` bypasses checking during that macro operation. If the file remains loaded, ChkSave may subsequently issue an inappropriate warning because its recorded date and time were not refreshed by the normal save hook.

## Limitations

- File changes are detected by comparing disk date/time information, not by comparing complete file contents.
- Hidden and system files are not monitored.
- No checking occurs while commands are actively being entered.
- Renaming a loaded file starts a new tracking history for the new filename.
- Reloading replaces unsaved contents in the current TSE buffer.
- Compare mode depends on `CmpFiles` being installed and usable.
- The hard-coded temporary pathname may need adjustment on a modern or restricted Windows installation.

## Troubleshooting

### No warning appears

- Confirm that ChkSave was compiled successfully.
- Confirm that `ChkSave` is present in the macro autoload list.
- Restart TSE after changing the autoload list.
- Test with a normal file rather than a hidden or system file.
- Allow TSE to remain idle for longer than the configured check interval.
- Confirm that the external program actually saved the file to disk.

### Compare does not work

Make sure TSE's `CmpFiles` macro is installed and can be run independently. ChkSave invokes it with `ExecMacro("cmpfiles")`.

### Temporary-file or access error

Check whether `C:\chksave.tse` can be created and removed. If not, edit `temp_filename` in the source so that it points to a writable directory, then recompile the macro.

### The macro behaves unexpectedly on 32-bit TSE

This version was created for TSE Pro 2.50e. Follow the original author's recommendation to use the appropriate ChgNot package for 32-bit TSE rather than assuming full compatibility with this older source.

## Version history

### README 1.0.0.0.0 — 02 September 2026

- Created the initial Markdown documentation from `CHKSAVE.S` and `FILE_ID.DIZ` in `chksave4.zip`.
- Added installation, operation, prompt, configuration, compatibility, limitation, and troubleshooting information.

### Original ChkSave macro history

- **Version 2:** Ignored hidden and system files and added notification before saving.
- **Version 3:** Fixed change detection when TSE used a 12-hour time display that did not show seconds.
- **Version 4:** Fixed a false external-change report after closing and reopening the same file during one TSE session.

Future README revisions can use sequential versions such as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## License

No explicit license is included in the supplied archive. The original author retains the applicable rights. Review the source comments and contact the author before redistributing a modified version if permission is uncertain.
