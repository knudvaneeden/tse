# LOADFIL1

**README version:** 1.0.0.0.5  
**Date and time:** 2026-09-16 22:15:00 CEST  
**Session name:** Create LOADFIL1 MarkDown Readme  
**Prepared by:** OpenAI Codex (GPT-5)

## Description

LOADFIL1 is a TSE SAL macro package containing `LOADFILE.S`, written by Dr. S. Schicktanz. The supplied original source identifies itself as **LoadFile.S version 0.8, dated 1996-07-01**. Package version **1.0.0.0.5** uses a safe Win32 helper DLL, activates its hooks through `Main()`, restores clean custom dialog footers on newer TSE versions, and uses English by default.

The macro extends TSE file-entry dialog boxes. After the compiled macro has been loaded, it installs event hooks that enhance file prompts and file-selection lists automatically.

The enhancements include:

- footer help showing the keys available in file-entry prompts;
- an extended file picker;
- selection of a file together with its directory;
- changing the current directory from the picker;
- a drive-selection list containing available drive letters and volume labels;
- support for local, removable, and detected network drives;
- use of the current file's directory as the initial file-picker directory;
- prompt text in German or English, selected at compile time.

No document text is modified merely by loading LOADFILE. Its purpose is to enhance TSE's file-entry interface.

## Files in the Package

| File | Purpose |
| --- | --- |
| `LOADFILE.S` | TSE SAL source code for the macro. |
| `loadfil1_dll.c` | Win32 DLL source code for drive enumeration and volume labels. |
| `loadfil1.def` | DLL export-definition file. |
| `build.bat` | Builds the DLL with Borland C++ 5.5.1 and compiles the SAL macro. |
| `FILE_ID.DIZ` | Original short package description. |
| `loadfil1_readme.md` | This documentation. |

After compilation, the compiler creates `LOADFILE.MAC`.

## Requirements

- The SemWare Editor (TSE) with a SAL compiler compatible with the source.
- Borland C++ 5.5.1 for building the supplied 32-bit Win32 DLL.
- Windows 10 or Windows 11.
- Permission to load compiled macros in TSE.

The original source used the DOS-only SAL commands `setDTA()`, `intr()`, and `FindFirst()`. These are not supported by Win32 TSE. Package version 1.0.0.0.2 replaces those calls with `loadfil1.dll`. The DLL uses the Win32 functions `GetLogicalDrives()` and `GetVolumeInformationA()`.

Version 1.0.0.0.1 passed a writable `string : cstrval` from SAL to the DLL. Running the macro caused a TSE access violation on the tested editor. Version 1.0.0.0.2 removes that unsafe interface completely. All three DLL functions now have no parameters and return only an integer. Volume-label characters are returned one at a time, so the DLL never reads from or writes to TSE-managed string memory.

## Language Selection

English is the default language when no language definition is supplied during compilation.

The source supports these compile-time definitions:

- `_ENG` — English prompts and the default;
- `_GER` — optional German prompts.

To compile the optional German edition, use the equivalent of this historical command-line definition:

```text
SC LOADFILE D_GER
```

When using a newer SAL compiler such as `SC32.EXE`, use the equivalent command-line definition syntax supported by that compiler. If no definition is supplied, the source selects English.

## Building LOADFIL1 Version 1.0.0.0.5

1. Extract `loadfil1.zip` into a working directory.
2. Open a command prompt in that directory.
3. Check the `BCC55` path near the beginning of `build.bat`. The supplied path is:

```text
g:\language\computer\cpp\embarcadero\borland\bcc55
```

4. Ensure that `SC32.EXE` can be found through `PATH` or the active command environment.
5. Run:

```text
build.bat
```

6. Confirm that the build creates both `loadfil1.dll` and `LOADFILE.MAC`.
7. Keep `loadfil1.dll` together with the compiled macro.

A separately compiled DLL can be followed by this SAL command:

```text
sc32 LOADFILE.S
```

That command produces the default English edition. Consult the compiler's command-line help when passing `_GER`, because definition syntax can differ between compiler generations.

### DLL Interface

The SAL source imports these parameterless Pascal-calling-convention functions from `loadfil1.dll`:

```text
LFResetDriveScan()
LFNextDrive()
LFNextLabelChar()
```

`LFResetDriveScan()` initializes a scan. `LFNextDrive()` returns the next drive number from 1 through 26, or zero when finished. It also prepares that drive's volume label internally. `LFNextLabelChar()` returns one label character as an integer, or zero at the end of the label. The DLL temporarily suppresses critical-error dialog boxes while checking a drive.

This stateful, parameterless interface deliberately avoids pointer passing, writable SAL strings, parameter-order differences, and stack cleanup involving arguments.

## Installing and Loading the Macro

1. Copy `LOADFILE.MAC` and `loadfil1.dll` to the same TSE macro directory.
2. Start TSE.
3. Load `LOADFILE.MAC` with TSE's macro-loading facility, or add it to the normal startup macro configuration.
4. Select `LOADFILE` from TSE's Macro menu once. `Main()` calls `WhenLoaded()` and installs the required hooks.
5. Open a file-entry command, such as TSE's file-open command, to verify that the new footer and picker functions are present.

In version 1.0.0.0.3, `Main()` explicitly calls `WhenLoaded()`. An `Installed` guard prevents the hooks from being installed twice when LOADFILE is executed repeatedly.

Version 1.0.0.0.4 also queues an internal `Ctrl+Alt+Shift+F12` event while the relevant dialog key definition is active. TSE processes that event after drawing its standard footer, allowing LOADFILE to apply its own footer afterward. The internal key is enabled only inside LOADFILE's filename prompt or picker context.

Version 1.0.0.0.5 clears the complete usable footer width before drawing LOADFILE's footer. This removes fragments of TSE's previous footer that remained visible at the left and right edges. English is now selected when neither `_ENG` nor `_GER` is defined.

## How to Use LOADFILE

After the macro is loaded, use TSE's ordinary commands that display a filename prompt or file-selection list. LOADFILE augments those dialogs automatically.

### File-Entry Prompt

In an edit/file-entry prompt:

| Key | Action |
| --- | --- |
| `Enter` | Accept the entered filename or selection. |
| `Up Arrow` / `Down Arrow` | Browse previous history entries. |
| `F2` | Open the enhanced file-selection list. |
| `Esc` | Cancel the prompt. |
| `Ctrl+Backspace` | Delete the word to the left of the cursor. |
| `Ctrl+F7` | Insert the current filename. |
| `Ctrl+F1` | Execute the optional `ASCII` macro, if it is installed. |

### Enhanced File-Selection List

| Key | Action |
| --- | --- |
| `Enter` | Select the highlighted file. |
| `F10` | Select the highlighted file and make its directory current. |
| `Shift+F10` | Make the selected directory current without accepting a file. |
| `F2` | Display the available-drive list. |
| `Esc` | Cancel and leave the selection list. |
| `Ctrl+F1` | Execute the optional `ASCII` macro, if it is installed. |

### Drive-Selection List

Press `F2` in the enhanced file-selection list. LOADFILE displays the detected drive letters and, when available, their volume labels. Select a drive to change the file picker's location to that drive.

### Diagnostic Key

The source defines this diagnostic key:

| Key | Action |
| --- | --- |
| `Ctrl+Alt+F8` | Display internal hook counters for troubleshooting. |

This command is mainly useful to developers who are checking whether the event hooks are balanced correctly.

## Normal Operating Sequence

1. Load `LOADFILE.MAC` in TSE and select `LOADFILE` from the Macro menu once.
2. Invoke TSE's normal file-open or edit-file command.
3. Type a filename directly, browse prompt history, or press `F2` for the enhanced picker.
4. Navigate to the required file or directory.
5. Press `Enter`, `F10`, or `Shift+F10`, depending on the required action.
6. Press `Esc` whenever the operation should be cancelled.

## Troubleshooting

### The default TSE footer remains visible

Versions through 1.0.0.0.3 applied their footers during the old startup hooks. Newer TSE versions subsequently redrew their standard footers, hiding the LOADFILE text even though the keys worked. Version 1.0.0.0.4 applies the custom footer through a queued internal event after the standard drawing. Replace `LOADFILE.MAC`, restart TSE, select LOADFILE from the Macro menu once, and open the file-edit prompt with `Alt+E`.

### German prompts are required

English is the built-in default. Recompile the source with the `_GER` definition using the syntax required by the installed SAL compiler.

### `Ctrl+F1` reports that the ASCII macro cannot be found

`Ctrl+F1` calls `ExecMacro("ASCII")`. Install the separate `ASCII` macro, change that key definition, or avoid using `Ctrl+F1`. The core LOADFILE features do not require the optional macro.

### TSE reports that `loadfil1.dll` cannot be found

Place `loadfil1.dll` in the same directory as `LOADFILE.MAC`. Restart TSE after replacing a DLL because Windows or TSE may keep a loaded DLL in memory.

### The compiler still reports `setDTA`, `intr`, or `FindFirst`

An original copy of `LOADFILE.S` is being compiled. Compile the updated source from package version 1.0.0.0.2. Those unsupported calls are absent from the updated `GetDriveLetters()` procedure.

### TSE reports an access violation

Do not use `loadfil1.dll` or `LOADFILE.MAC` from version 1.0.0.0.1. Delete or replace both files, restart TSE to release the cached DLL, build version 1.0.0.0.2, and keep the new DLL and macro together. Mixing the version 1.0.0.0.2 macro with the older DLL will fail because their exported interfaces differ.

### The DLL does not link

Verify the `BCC55` path in `build.bat` and confirm that `c0d32.obj`, `import32.lib`, and `cw32.lib` exist in the Borland library directory. Run the build from the directory containing all supplied source files.

### The footer does not fit

The source only displays some footer text when the prompt window is wide enough. Increase the TSE window width and try again.

### Hook diagnostics appear unbalanced

Press `Ctrl+Alt+F8` to display the internal hook counters. Reloading the macro or restarting TSE may reset the test environment. Do not repeatedly load multiple copies of the macro while troubleshooting.

## Uninstalling or Disabling LOADFILE

1. Remove `LOADFILE.MAC` from the startup or automatic-load configuration.
2. Restart TSE so that the hooks installed by the macro are no longer active.
3. Optionally remove `LOADFILE.MAC` from the macro directory.

## Original Source History

| Source version | Date | Change |
| --- | --- | --- |
| 0.8 | 1996-07-01 | Corrected hook balancing, based on feedback from G.D.B./SemWare. |
| 0.7 | 1996-05-01 | Removed the requirement for a trailing backslash during directory recognition. |
| 0.6 | 1996-04-18 | Corrected directory handling. |
| 0.5 | 1996-04-15 | Original version. |

## README Version History

| README version | Date and time | Change |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-16 14:41:01 CEST | Initial Markdown description, help, installation, compilation, usage, key reference, troubleshooting, and source-history documentation. |
| 1.0.0.0.1 | 2026-09-16 16:01:20 CEST | Documented the Win32 helper DLL, Borland C++ 5.5.1 build, updated installation, and the removal of unsupported DOS-only SAL calls. |
| 1.0.0.0.2 | 2026-09-16 21:00:00 CEST | Replaced the crashing writable-string DLL interface with three parameterless integer-only functions; added restart and version-mixing warnings. |
| 1.0.0.0.3 | 2026-09-16 21:15:00 CEST | Made `Main()` activate the hooks and added an installation guard to prevent duplicate hooks. |
| 1.0.0.0.4 | 2026-09-16 21:45:00 CEST | Restored custom filename-prompt and picker footers after newer TSE versions redraw their standard footer; shortened footer text to fit. |
| 1.0.0.0.5 | 2026-09-16 22:15:00 CEST | Made English the default and cleared the complete old footer before drawing LOADFILE's custom footer. |

Future revisions should increment the final component sequentially: `1.0.0.0.6`, `1.0.0.0.7`, and so on.

## Credits

- Original macro author: Dr. S. Schicktanz.
- Original package: `loadfil1.zip`.
- README preparation: OpenAI Codex (GPT-5).

## Important Note

Back up the original package and test the compiled macro in a controlled TSE setup before adding it to permanent startup configuration. This is especially important because the source uses operating-system interfaces originating from the DOS-era TSE environment.
