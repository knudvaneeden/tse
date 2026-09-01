# CHGNOTIF 1.6 for TSE Pro/32

**README version:** 1.0.0.0.0  
**Created:** 2026-09-01 22:33:29 UTC  
**Original macro author:** Chris Antos

## Description

CHGNOTIF detects when a file that is open in The SemWare Editor (TSE) has been changed by another program or by another TSE session. When TSE becomes active again, the macro reports the external change and lets you decide whether to reload the file.

For example, if a file is open in TSE and you edit and save the same file in Notepad, CHGNOTIF warns you when you return to TSE. This helps prevent the externally saved changes from being accidentally overwritten.

The package uses the supplied 32-bit Windows DLL to receive file-system change notifications. It therefore does not need to continuously poll the files and uses no CPU while idle.

## Requirements

- TSE Pro/32 version 2.6 or later.
- A 32-bit Windows environment supported by the installed TSE version.
- Both `ChgNotif.s` and `chgnotif.dll` must be available to TSE.
- TSE 2.5 is not supported because it is a DOS application and cannot receive native Windows file-change notifications.

## Package contents

| File | Purpose |
| --- | --- |
| `ChgNotif.s` | TSE SAL source for the macro. |
| `chgnotif.dll` | 32-bit Windows notification DLL used by the macro. |
| `ChgNotif.txt` | Original documentation and version history. |
| `file_id.diz` | Short package description. |
| `src/ChgNotif.c` | C source code for the DLL. |
| `src/ChgNotif.def` | DLL module definition and exported functions. |
| `src/makefile` | Original Microsoft C build instructions. |

## Installation

1. Extract `chgnot16.zip` to a temporary directory.
2. Copy `ChgNotif.s` and `chgnotif.dll` to a directory in which TSE can find macros and their DLL dependencies. Keeping both files in the same TSE macro directory is recommended.
3. Start TSE Pro/32.
4. Open `ChgNotif.s` in TSE.
5. Choose **Macro -> Compile** to compile the SAL source.
6. Load or execute the compiled `ChgNotif` macro.
7. Complete the first-run configuration displayed by the macro.

Do not use `src/ChgNotif.c` in place of `chgnotif.dll`; the C file is source code for rebuilding the DLL and is not needed for normal operation.

## How to run

Run the macro from TSE by executing:

```text
ChgNotif
```

After it has been loaded, CHGNOTIF works in the background. Open a file in TSE and edit the same file in another application. Save it in that application and return to TSE. CHGNOTIF should report the change and offer the appropriate action, such as reloading the file.

To open the options menu, execute:

```text
ChgNotif -o
```

Automatic reloading of files that have not been modified inside TSE is optional and is disabled by default.

## Typical test

1. Load CHGNOTIF in TSE.
2. Open an existing text file in TSE.
3. Open the same file in Notepad or another editor.
4. Change and save the file in the other editor.
5. Return to TSE.
6. Confirm that CHGNOTIF reports the external modification.
7. Choose reload if you want the TSE buffer to reflect the saved external version.

If both the TSE buffer and the disk file have changed, review the choices carefully. The macro can offer use of `CMPFILES` for an interactive manual merge when that companion macro is available.

## Notes and cautions

- Saving over another file currently loaded in TSE with **Save As** or **Write Block** can also produce a notification.
- Keep `chgnotif.dll` available for as long as the macro is loaded.
- The supplied DLL is a legacy 32-bit component. A 64-bit-only host process cannot load it.
- The original DLL makefile targets Microsoft C and is included for developers; rebuilding the DLL is not required for ordinary use.
- If the macro does not react, verify that you compiled and loaded `ChgNotif.s`, that the DLL is in TSE's DLL search path, and that you are running TSE Pro/32 2.6 or later.

## Options

Use `ChgNotif -o` to view or change the available settings. The principal setting is automatic reload. When enabled, a disk file that changed externally may be reloaded automatically if its TSE buffer has no unsaved edits. Leaving this disabled gives you explicit control over every reload.

## Public services for other SAL macros

CHGNOTIF 1.6 exposes public macro procedures that other TSE SAL macros can call, including services to:

- stop watching the current file;
- mark the current file as changed, gone, or unchanged;
- announce that an external change is expected;
- reset the expected-change state;
- obtain the CHGNOTIF version.

These interfaces are intended for macro developers. The normal user only needs to compile and load `ChgNotif.s`.

## Troubleshooting

### The macro cannot load `chgnotif.dll`

Place `chgnotif.dll` in the same macro directory as the compiled CHGNOTIF macro or in another directory searched by TSE/Windows, then restart or reload the macro.

### No notification appears

Make sure the externally edited file is already open in TSE, save the external edit to disk, and then reactivate TSE. Also verify that CHGNOTIF is loaded and the file has not been excluded from watching.

### TSE reports that the macro needs a newer editor

Use TSE Pro/32 version 2.6 or later. The macro deliberately rejects older or non-Windows TSE builds.

### Reloading would discard TSE changes

Do not reload blindly. If the buffer contains unsaved changes and the disk copy also changed, compare or merge the two versions first. If installed, `CMPFILES` can assist with manual merging.

## Original CHGNOTIF release history summary

- **CHGNOTIF 1.6 (2001-09-09):** Ignores transient file-attribute changes that could cause false notifications under Windows XP or eTrust.
- **CHGNOTIF 1.5 (2001-04-13):** Added public control macros, nested expected-change tracking, and version reporting.
- **CHGNOTIF 1.4 (1999-02-10):** Added support for TSE 3.0 file-save hooks.
- Earlier releases corrected notification handling, multi-instance shutdown, directory tracking, and new-file behavior.

## README version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-01 22:33:29 | Initial Markdown README created from the contents of `chgnot16.zip`. |

For later README revisions, increment the final component sequentially, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

