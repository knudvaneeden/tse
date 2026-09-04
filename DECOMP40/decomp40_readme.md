# DeComp 4.00 for TSE — README

**README version:** 1.0.0.0.0  
**Package version:** 4.00 (2001-06-05)  
**README created:** 2026-09-04 23:17:29 CEST (UTC+02:00)  
**Original author:** Dieter Kössl  
**Target editor:** The SemWare Editor Professional (TSE Pro)

## Description

DeComp 4.00 is a collection of TSE SAL macros for inspecting, editing, and rebuilding recorded TSE keyboard macros.

The package contains three main programs:

- `decomp.s` reads a binary TSE keyboard-macro file and creates an editable text listing.
- `recomp.s` converts an edited text listing back into a binary keyboard-macro file.
- `editkbd.s` interactively edits the keyboard macros that are currently loaded in TSE.

DeComp was written for TSE Pro 2.5 and TSE Pro/32 2.8–3.0. The package uses undocumented, version-dependent details of the historical keyboard-macro file format. Back up every `.kbd` file before using these tools, especially with a newer TSE release.

## Package contents

| File | Purpose |
|---|---|
| `decomp.s` | Decompiles a binary `.kbd` file into a readable `.k` file. |
| `recomp.s` | Recompiles a `.k` listing into a binary `.kbd` file. |
| `editkbd.s` | Interactively edits the currently loaded key macros. |
| `decomp.si` | Shared SAL include file required by the macros. |
| `decomp.doc` | Original documentation. |
| `keytable.dat` | Default US key-code translation table for 16-bit TSE 2.5. |
| `keytable.001` | Alternate copy of the US translation table. |
| `keytable.049` | German translation table for 16-bit TSE 2.5. |
| `file_id.diz` | Short description of the original package. |

## Requirements

- A compatible installation of TSE Pro.
- The SAL compiler supplied with TSE, such as `sc32.exe` for a 32-bit TSE installation.
- Write permission in the directory where output files will be created.
- A safe backup of the original keyboard-macro file.

For 16-bit TSE 2.5, keep `keytable.dat` with the macros. For a German keyboard, copy `keytable.049` over `keytable.dat` before compiling or running the package. TSE Pro/32 does not use this translation table.

## Installation and compilation

1. Extract all files from `decomp40.zip` into one directory.
2. Keep `decomp.si` in the same directory as the three `.s` source files while compiling.
3. Open a command prompt in that directory.
4. Compile the programs with the appropriate SAL compiler. For TSE Pro/32, use:

```bat
sc32 decomp.s
sc32 recomp.s
sc32 editkbd.s
```

5. Confirm that all three files compile without errors.
6. Place the resulting compiled macros where TSE can find and execute them, according to the macro-directory configuration of your TSE installation.

If `editkbd.s` cannot execute DeComp or ReComp, make sure the compiled `decomp` and `recomp` macros are on TSE's macro search path.

## Quick start: decompile, edit, and rebuild

1. Save the keyboard macros you want to edit to a `.kbd` file from within TSE.
2. Make a backup copy of that `.kbd` file.
3. Run DeComp and supply the keyboard-macro filename:

```text
decomp filename.kbd
```

   If no filename is supplied, DeComp prompts for one. Press Enter at the prompt to choose a file from the pick list.

4. DeComp creates and opens a text listing with the same base name and the extension `.k`:

```text
filename.kbd  ->  filename.k
```

5. Edit the `.k` file, observing the format rules described below.
6. While the `.k` file is current in TSE, run:

```text
recomp
```

   ReComp writes a `.kbd` file with the same base name. If the current file is not a `.k` file, it asks which listing to compile.

7. When prompted, choose whether the newly compiled macros should be loaded immediately.

To rebuild and automatically load the macros, use:

```text
recomp -load
```

DeComp and ReComp show progress on the status line. Press `Escape` to interrupt either operation.

## Using EditKbd

Run:

```text
editkbd
```

EditKbd decompiles the keyboard macros currently loaded in TSE and displays their assigned hotkeys.

In the macro list:

- Press `F2` to change the selected macro's hotkey.
- Press `Delete` to remove the selected macro.
- Press `Insert` to add a macro.
- Press `Enter` to edit the recorded keystrokes of the selected macro.
- Press `Escape` to finish editing and respond to the save prompt.

In the keystroke list:

- Press `Delete` to remove a keystroke.
- Press `Insert` to add a keystroke.
- Press `Enter` to change a keystroke.
- On TSE Pro/32, most keys and key combinations can also be entered directly.
- On TSE Pro/32 3.0, use `Ctrl+Z` and `Ctrl+Y` for undo and redo.

Press `Escape` once to leave the keystroke list and again to leave the macro list. The changes are recompiled and loaded only after you confirm that they should be saved. To preserve the changes permanently, save the keyboard macros from TSE afterward.

### Scrap macro note

The scrap macro appears under `<Enter>` or `<GreyEnter>`, even if another key replays it. To change the scrap macro, edit that entry. Only one scrap macro can exist in a keyboard-macro file.

## `.k` key-listing format

A listing contains macro hotkeys followed by their recorded keystrokes. For example:

```text
; A comment line
<Ctrl F2>              ; macro hotkey starts in column 1
  <H>                  ; recorded keys must be indented
  <e>
  <l>
  <l>
  <o>
  <Ctrl M>             ; recording terminator; normally leave unchanged
```

Observe these rules:

- A macro hotkey must begin in column 1.
- Each recorded keystroke must be indented by at least one space.
- Every macro must contain at least one keystroke.
- Blank lines are allowed and are ignored.
- Lines beginning with `;` are comments and are ignored.
- Text after the closing `>` of a key definition is treated as an inline comment.
- Key names use TSE SAL notation, such as `<Ctrl F2>`.
- A hexadecimal value from 0 through 65535 can be used when SAL has no recognized textual key name.
- A file can contain at most 20 ordinary key macros, plus one scrap macro.
- Leave the final recording-termination key unchanged for compatibility. In the standard interface this is normally `<Ctrl M>`.

The TSE user's guide, Appendix D, documents the available key codes. The `ShowKey` macro can also help determine how TSE identifies a key.

## Troubleshooting

### Invalid macro file format

The input may not be a TSE keyboard-macro file, or its binary format may not match the TSE versions supported by this package.

### Macro is empty

The hotkey has no indented keystrokes beneath it. Add at least one keystroke and verify the indentation.

### Invalid macro format

Look for a missing `;` on a comment, malformed angle brackets, an unindented keystroke, or a first macro with no hotkey.

### Invalid key code

Correct the name inside `<...>` or use a valid numeric key code. A number in range is not necessarily a real key supported by the keyboard.

### Scrap macro defined more than once

Remove the extra `<Enter>` or `<GreyEnter>` scrap-macro definition.

### Too many macros

Reduce the listing to no more than 20 ordinary macros. The scrap macro is counted separately.

### Cannot execute macro

EditKbd could not find the compiled DeComp or ReComp macro. Put both on TSE's macro search path.

### Odd numeric key names in 16-bit TSE

The active keyboard layout may not match `keytable.dat`. The included German table can be enabled by replacing `keytable.dat` with a copy of `keytable.049` before compilation or use.

## Compatibility and safety

The binary format handled by this package was documented through reverse engineering and is explicitly version-dependent. Compatibility is stated for TSE Pro 2.5, 2.6, 2.8, and 3.0; operation with later TSE versions is not guaranteed.

Recommended precautions:

1. Work on copies of all `.kbd` files.
2. Test rebuilt macros in a disposable TSE configuration first.
3. Do not overwrite the only known-good keyboard-macro file.
4. Keep the original `decomp40.zip` unchanged for recovery.

## License and disclaimer

The original author donated these programs to the public domain and allowed them to be used or altered. The original documentation also states that use is at the user's own risk.

## README version history

| README version | Date and time | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-04 23:17:29 CEST | Initial Markdown documentation based on the supplied DeComp 4.00 archive and its original source documentation. |

For future README revisions, increment the final component first:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
```

When a larger documentation milestone is reached, increment an earlier component as appropriate.
