# HEX — Hexadecimal Character Viewer and Inserter

**Session:** Create HEX MarkDown Readme  
**README version:** 1.0.0.0.0  
**Date:** 2026-09-10  
**Time:** 21:38:45 UTC  

## Description

`HEX.S` is a small macro for The SemWare Editor (TSE) that displays the hexadecimal value of the character at the cursor and lets you edit that value. When the value is accepted, the macro inserts the corresponding character at the current cursor position.

The supplied source binds the macro to the `F3` key.

## Package contents

| File | Purpose |
| --- | --- |
| `HEX.S` | TSE SAL source code for the HEX macro |

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- This source is intended for the classic TSE SAL environment.
- A writable location for the compiled `HEX.MAC` file.

## Compile the macro

1. Extract `hex.zip` to a directory of your choice.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

   ```text
   sc32 HEX.S
   ```

4. A successful compilation creates `HEX.MAC`.
5. Copy `HEX.MAC` to a directory searched by TSE, such as the TSE `MAC` directory, or leave it in the current directory when loading it from there.

## Load and run

1. Start TSE.
2. Load the compiled macro by entering:

   ```text
   LoadMacro HEX
   ```

3. Place the cursor on the character whose value you want to inspect.
4. Press `F3`.
5. The **Hex Value at Cursor:** prompt displays the current character value in hexadecimal.
6. Keep the displayed value or type another hexadecimal value, such as `41` for uppercase `A`.
7. Press `Enter` to insert the corresponding character at the cursor. Press `Esc` to cancel without inserting anything.

## Examples

| Hex value | Inserted character |
| --- | --- |
| `20` | Space |
| `30` | `0` |
| `41` | `A` |
| `61` | `a` |
| `0` or `00` | NUL character, character value zero |

## Input and error handling

- Enter hexadecimal digits only: `0` through `9` and `A` through `F` (uppercase or lowercase).
- If the entry cannot be converted to a nonzero hexadecimal value, the macro sounds an alarm and displays `Non-Hex Input.`
- Zero is handled separately so that a NUL character can be inserted.
- The macro uses `InsertText()`, so it inserts the selected character at the cursor; it does not explicitly replace the character already under the cursor.
- Inserting control characters, including NUL, may produce results that are not visibly apparent and may not be suitable for ordinary text files.

## Key assignment

The source contains this key definition:

```text
<F3> InsertHex()
```

If `F3` is already assigned to another command or macro, edit this line in `HEX.S`, choose a different key, and recompile the source.

## Unload or reload

To unload the macro, use:

```text
PurgeMacro HEX
```

After recompiling the source, purge and load the macro again—or restart TSE—to ensure the updated `HEX.MAC` is active.

## Version numbering

README revisions use the sequence `1.0.0.0.0`, `1.0.0.0.1`, `1.0.0.0.2`, and so on. Increment the final component whenever this documentation is updated.

## Version history

### 1.0.0.0.0 — 2026-09-10 21:38:45 UTC

- Initial Markdown documentation.
- Added a description of the macro and its `F3` key binding.
- Added compilation, loading, operating, and unloading instructions.
- Documented hexadecimal input, error handling, NUL insertion, and key conflicts.
