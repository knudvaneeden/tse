# MARKTOKN

## Package information

- **Package version:** 1.0.0.0.1
- **Created:** 2026-09-21 17:58:04 UTC
- **Original macro:** `MarkTokn.s`
- **Original author:** Carlo Hogeveen
- **Original source date:** 2004-05-24
- **Supported editor:** The SemWare Editor Professional (TSE Pro) 2.5 and newer

## Description

MARKTOKN provides token-based block selection in TSE. It is intended as a more convenient alternative to the usual Windows/CUA behavior of selecting text with **Ctrl+Shift+Left** and **Ctrl+Shift+Right**.

A token is either:

- one complete word, as determined by TSE's current word set; or
- one non-word character.

Repeated commands extend or reduce the same non-inclusive marked block in either direction. The macro also contains context-sensitive handling for whitespace at the beginning of a line.

## Files

- `MarkTokn.s` - original TSE SAL source code.
- `File_Id.diz` - original short package description.
- `marktokn.ini` - package configuration placeholder and compatibility note.
- `marktokn_readme.md` - this description and help file.

## Requirements

- TSE Pro 2.5 or newer.
- A TSE SAL compiler suitable for the installed TSE version, such as `sc32.exe` for 32-bit TSE.
- Permission to edit and compile the active TSE user-interface (`.ui`) source.

## Installation

1. Extract all files from `marktokn1.0.0.0.1.zip` into a working directory.
2. Compile `MarkTokn.s` with the SAL compiler. For example:

   ```text
   sc32 MarkTokn.s
   ```

3. Confirm that compilation creates `MarkTokn.mac`.
4. Put `MarkTokn.mac` in a directory from which TSE can load macros, normally TSE's macro directory.
5. Add the key definitions shown below to the appropriate key-definition section of your `.ui` source.
6. Recompile the `.ui` source and restart or reload TSE as required by your setup.

## Recommended key definitions

Add these definitions outside `MarkTokn.s`:

```text
<CtrlShift CursorRight>       ExecMacro("MarkTokn forwards")
<CtrlShift GreyCursorRight>   ExecMacro("MarkTokn forwards")
<CtrlShift CursorLeft>        ExecMacro("MarkTokn backwards")
<CtrlShift GreyCursorLeft>    ExecMacro("MarkTokn backwards")
```

The normal and grey cursor-key variants allow the bindings to work with both sets of cursor keys.

The keys cannot safely be defined inside this macro because MARKTOKN deliberately unloads itself when it is no longer maintaining a marked block.

## How to run

### Using the recommended keys

1. Open a text file in TSE.
2. Put the cursor at or next to the token where selection should begin.
3. Press **Ctrl+Shift+Right** to mark the next token.
4. Press **Ctrl+Shift+Right** repeatedly to extend the marked block to the right.
5. Press **Ctrl+Shift+Left** to extend or reduce the marked block toward the left.
6. Move or clear the block normally when selection is complete. MARKTOKN unloads itself once the active block is no longer a non-inclusive block.

### Running the macro directly

The macro can also be invoked with an explicit direction:

```text
ExecMacro("MarkTokn forwards")
ExecMacro("MarkTokn backwards")
```

Running MARKTOKN without a parameter displays an informative message explaining its purpose, the two supported command forms, the version, and the updating LLM. Selection is performed only when the parameter is exactly `forwards` or `backwards`.

## CuaMark compatibility

If TSE's `CuaMark` macro already owns these keys, the bindings may conflict. The original MARKTOKN documentation recommends commenting out the corresponding `WordLeft()` and `WordRight()` key-definition line in `CuaMark`, then checking that customization again after a TSE upgrade.

Keep a backup before changing TSE or third-party macro sources.

## Configuration file

`marktokn.ini` is included so the package has a conventional initialization file. Version 1.0.0.0.1 of `MarkTokn.s` does **not** read an INI file and has no configurable runtime values. Selection behavior is controlled by TSE's current word set and by the `forwards` or `backwards` macro parameter.

## Troubleshooting

### The keys do nothing

- Confirm that `MarkTokn.mac` was created successfully.
- Confirm that it is in TSE's macro search path.
- Confirm that the edited `.ui` file was compiled and is the interface currently loaded by TSE.
- Check whether another macro, especially `CuaMark`, redefines the same keys.

### Selection moves in the wrong direction

Check the spelling of the macro parameters. Use exactly `forwards` for the right key and `backwards` for the left key.

### Word boundaries are unexpected

MARKTOKN uses TSE's current word set. Change the applicable TSE word-set configuration if different characters must count as part of a word.

### The macro disappears from the loaded-macro list

This is intentional. MARKTOKN hooks TSE's idle processing while it maintains a non-inclusive selection, then purges itself when that selection state ends.

## Version history

### 1.0.0.0.1 - 2026-09-21

- Added an informative message when MARKTOKN is run without a valid direction parameter.
- Kept normal `forwards` and `backwards` key-driven operation silent.
- Added the package version and updating LLM name to the source and message.

### 1.0.0.0.0 - 2026-09-21

- Added this Markdown description, installation guide, usage help, and troubleshooting information.
- Added `marktokn.ini` as a documented placeholder.
- Preserved the original `MarkTokn.s` and `File_Id.diz` files.
